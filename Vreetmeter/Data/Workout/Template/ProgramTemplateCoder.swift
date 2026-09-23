import Foundation
import SwiftData
import CoreTransferable
import UniformTypeIdentifiers

nonisolated enum ProgramTemplateError: LocalizedError {
    case unsupportedSchemaVersion(Int)
    case invalid(String)
    case decoding(String)

    var errorDescription: String? {
        switch self {
        case .unsupportedSchemaVersion(let version):
            "This template uses schema version \(version), but only version \(ProgramTemplate.currentSchemaVersion) is supported."
        case .invalid(let message):
            message
        case .decoding(let message):
            message
        }
    }
}

enum ProgramTemplateCoder {
    static func decode(_ data: Data) throws -> ProgramTemplate {
        let template: ProgramTemplate
        do {
            template = try JSONDecoder().decode(ProgramTemplate.self, from: data)
        } catch let error as DecodingError {
            throw ProgramTemplateError.decoding(describe(error))
        }

        if template.schemaVersion > ProgramTemplate.currentSchemaVersion {
            throw ProgramTemplateError.unsupportedSchemaVersion(template.schemaVersion)
        }
        try validate(template)
        return template
    }

    static func encode(_ template: ProgramTemplate) throws -> Data {
        let encoder = JSONEncoder()
        encoder.outputFormatting = [.prettyPrinted, .sortedKeys, .withoutEscapingSlashes]
        return try encoder.encode(template)
    }

    /// Creates a program, and any exercises missing from the library, from a template.
    @discardableResult
    static func importProgram(_ template: ProgramTemplate, into context: ModelContext) throws -> WorkoutProgram {
        var cache: [String: Exercise] = [:]

        for info in template.exercises ?? [] {
            let exercise = try Exercise.findOrCreate(named: info.name, in: context, cache: &cache)
            if let instructions = info.instructions { exercise.instructions = instructions }
            if let videoURL = info.videoURL { exercise.videoURL = videoURL }
        }

        let program = WorkoutProgram(name: template.name, notes: template.notes)
        context.insert(program)

        for (weekIndex, weekTemplate) in template.expandedWeeks().enumerated() {
            let week = ProgramWeek(name: weekTemplate.name, sortOrder: weekIndex, block: weekTemplate.block, note: weekTemplate.note)
            program.weeks.append(week)

            for (dayIndex, dayTemplate) in weekTemplate.days.enumerated() {
                let day = ProgramDay(name: dayTemplate.name, sortOrder: dayIndex, kind: dayTemplate.kind ?? .training)
                week.days.append(day)

                for (exerciseIndex, exerciseTemplate) in (dayTemplate.exercises ?? []).enumerated() {
                    let exercise = try Exercise.findOrCreate(named: exerciseTemplate.exercise, in: context, cache: &cache)
                    let planned = PlannedExercise(sortOrder: exerciseIndex)
                    day.exercises.append(planned)
                    planned.exercise = exercise

                    planned.substitutions = try (exerciseTemplate.substitutions ?? []).map {
                        try Exercise.findOrCreate(named: $0, in: context, cache: &cache)
                    }
                    planned.supersetGroup = exerciseTemplate.superset
                    planned.warmupSets = exerciseTemplate.warmupSets ?? ""
                    planned.workingSets = exerciseTemplate.sets
                    planned.repTarget = exerciseTemplate.reps
                    planned.earlyRPE = exerciseTemplate.earlyRPE
                    planned.lastRPE = exerciseTemplate.lastRPE
                    planned.restMinSeconds = exerciseTemplate.rest?.min
                    planned.restMaxSeconds = exerciseTemplate.rest?.max
                    planned.intensityTechnique = exerciseTemplate.technique
                    planned.notes = exerciseTemplate.notes
                }
            }
        }

        return program
    }

    static func template(for program: WorkoutProgram) -> ProgramTemplate {
        var infos: [String: ProgramTemplate.ExerciseInfo] = [:]
        func reference(_ exercise: Exercise?) -> String {
            guard let exercise else { return "" }
            if exercise.instructions != nil || exercise.videoURL != nil {
                infos[Exercise.normalizedName(exercise.name)] = ProgramTemplate.ExerciseInfo(
                    name: exercise.name,
                    instructions: exercise.instructions,
                    videoURL: exercise.videoURL
                )
            }
            return exercise.name
        }

        let weeks = program.sortedWeeks.map { week in
            ProgramTemplate.Week(
                name: week.name,
                block: week.block,
                note: week.note,
                repeatCount: nil,
                days: week.sortedDays.map { day in
                    ProgramTemplate.Day(
                        name: day.name,
                        kind: day.kind,
                        exercises: day.kind == .training ? day.sortedExercises.map { planned in
                            ProgramTemplate.Exercise(
                                exercise: reference(planned.exercise),
                                substitutions: planned.substitutions.isEmpty ? nil : planned.substitutions.map { reference($0) },
                                superset: planned.supersetGroup,
                                warmupSets: planned.warmupSets.isEmpty ? nil : planned.warmupSets,
                                sets: planned.workingSets,
                                reps: planned.repTarget,
                                earlyRPE: planned.earlyRPE,
                                lastRPE: planned.lastRPE,
                                rest: planned.restMinSeconds.map { ProgramTemplate.Rest(min: $0, max: planned.restMaxSeconds) },
                                technique: planned.intensityTechnique,
                                notes: planned.notes
                            )
                        } : nil
                    )
                }
            )
        }

        return ProgramTemplate(
            schemaVersion: ProgramTemplate.currentSchemaVersion,
            name: program.name,
            notes: program.notes,
            exercises: infos.isEmpty ? nil : infos.values.sorted { $0.name < $1.name },
            weeks: weeks
        )
    }

    private static func validate(_ template: ProgramTemplate) throws {
        if template.name.trimmingCharacters(in: .whitespaces).isEmpty {
            throw ProgramTemplateError.invalid("The program needs a name.")
        }
        for week in template.weeks {
            if let count = week.repeatCount, count < 1 {
                throw ProgramTemplateError.invalid("\(week.name): repeat must be at least 1.")
            }
            for day in week.days {
                for exercise in day.exercises ?? [] {
                    if exercise.exercise.trimmingCharacters(in: .whitespaces).isEmpty {
                        throw ProgramTemplateError.invalid("\(week.name), \(day.name): an exercise has no name.")
                    }
                    if exercise.sets < 0 {
                        throw ProgramTemplateError.invalid("\(week.name), \(day.name), \(exercise.exercise): sets cannot be negative.")
                    }
                }
            }
        }
    }

    private static func describe(_ error: DecodingError) -> String {
        func path(_ context: DecodingError.Context) -> String {
            let components = context.codingPath.map { $0.intValue.map { "[\($0)]" } ?? ".\($0.stringValue)" }.joined()
            return components.isEmpty ? "the root" : String(components.drop { $0 == "." })
        }

        switch error {
        case .keyNotFound(let key, let context):
            return "Missing \"\(key.stringValue)\" at \(path(context))."
        case .typeMismatch(_, let context), .valueNotFound(_, let context):
            return "Unexpected value at \(path(context)): \(context.debugDescription)"
        case .dataCorrupted(let context):
            return "Invalid data at \(path(context)): \(context.debugDescription)"
        @unknown default:
            return error.localizedDescription
        }
    }
}

/// A program exported as a JSON file, for sharing.
nonisolated struct ProgramTemplateFile: Transferable {
    let name: String
    let data: Data

    static var transferRepresentation: some TransferRepresentation {
        DataRepresentation(exportedContentType: .json) { $0.data }
            .suggestedFileName { $0.name + ".json" }
    }
}
