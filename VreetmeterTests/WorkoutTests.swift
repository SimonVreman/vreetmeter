import Foundation
import SwiftData
import Testing
@testable import Vreetmeter

private let templateJSON = """
{
  "schemaVersion": 1,
  "name": "Test Program",
  "exercises": [{ "name": "Squat", "videoURL": "https://example.com/squat" }],
  "weeks": [
    {
      "name": "Week {n}",
      "block": "Block 1",
      "repeat": 2,
      "days": [
        {
          "name": "Day A",
          "exercises": [
            { "exercise": "Squat", "substitutions": ["Leg Press"], "warmupSets": "1-2", "sets": 3, "reps": "6-8",
              "earlyRPE": "~8", "lastRPE": "9", "rest": { "min": 120, "max": 180 }, "technique": "Dropset" },
            { "exercise": "squat ", "superset": "A", "sets": 2, "reps": "10" }
          ]
        },
        { "name": "Rest", "kind": "optionalRest" },
        { "name": "Day B", "exercises": [{ "exercise": "Bench Press", "sets": 3, "reps": "4, 6, 8" }] }
      ]
    },
    { "name": "Deload", "note": "Train lighter", "days": [{ "name": "Day A", "exercises": [] }] }
  ]
}
"""

/// Containers must outlive their contexts, so keep them around for the duration of the test run.
@MainActor private var containers: [ModelContainer] = []

@MainActor
private func makeContext() throws -> ModelContext {
    let container = try ModelContainer(
        for: WorkoutProgram.self, WorkoutSession.self, Exercise.self,
        configurations: ModelConfiguration(isStoredInMemoryOnly: true)
    )
    containers.append(container)
    return ModelContext(container)
}

@MainActor
private func importTestProgram(into context: ModelContext) throws -> WorkoutProgram {
    let template = try ProgramTemplateCoder.decode(Data(templateJSON.utf8))
    let program = try ProgramTemplateCoder.importProgram(template, into: context)
    try context.save()
    return program
}

@MainActor
struct ProgramTemplateTests {
    @Test func expandsRepeatedWeeks() throws {
        let template = try ProgramTemplateCoder.decode(Data(templateJSON.utf8))
        let weeks = template.expandedWeeks()
        #expect(weeks.map(\.name) == ["Week 1", "Week 2", "Deload"])
        #expect(weeks.allSatisfy { $0.repeatCount == nil })
        #expect(weeks[1].block == "Block 1")
    }

    @Test func rejectsNewerSchemaVersions() {
        let json = #"{ "schemaVersion": 99, "name": "Future", "weeks": [] }"#
        #expect(throws: ProgramTemplateError.self) { try ProgramTemplateCoder.decode(Data(json.utf8)) }
    }

    @Test func reportsWhereDecodingFailed() {
        let json = #"{ "schemaVersion": 1, "name": "Broken", "weeks": [{ "name": "Week 1", "days": [{ "name": "A", "exercises": [{ "exercise": "Squat", "reps": "5" }] }] }] }"#
        do {
            _ = try ProgramTemplateCoder.decode(Data(json.utf8))
            Issue.record("Expected decoding to fail")
        } catch {
            let message = error.localizedDescription
            #expect(message.contains("sets"))
            #expect(message.contains("weeks[0].days[0].exercises[0]"))
        }
    }

    @Test func importsProgramStructure() throws {
        let context = try makeContext()
        let program = try importTestProgram(into: context)

        #expect(program.name == "Test Program")
        #expect(program.sortedWeeks.map(\.name) == ["Week 1", "Week 2", "Deload"])
        #expect(program.sortedWeeks[2].note == "Train lighter")
        #expect(program.trainingDays.count == 5)

        let dayA = try #require(program.sortedWeeks.first?.sortedDays.first)
        let squat = try #require(dayA.sortedExercises.first)
        #expect(squat.exercise?.name == "Squat")
        #expect(squat.exercise?.videoURL == "https://example.com/squat")
        #expect(squat.substitutions.map(\.name) == ["Leg Press"])
        #expect(squat.warmupSets == "1-2")
        #expect(squat.workingSets == 3)
        #expect(squat.repTarget == "6-8")
        #expect(squat.restMinSeconds == 120 && squat.restMaxSeconds == 180)
        #expect(squat.intensityTechnique == "Dropset")
        #expect(dayA.sortedExercises[1].supersetGroup == "A")

        #expect(program.sortedWeeks[0].sortedDays[1].kind == .optionalRest)
    }

    @Test func sharesExercisesByName() throws {
        let context = try makeContext()
        _ = try importTestProgram(into: context)
        _ = try importTestProgram(into: context)

        let names = try context.fetch(FetchDescriptor<Exercise>()).map(\.name).sorted()
        #expect(names == ["Bench Press", "Leg Press", "Squat"])
    }

    @Test func exportRoundTrips() throws {
        let context = try makeContext()
        let program = try importTestProgram(into: context)

        let exported = ProgramTemplateCoder.template(for: program)
        let decoded = try ProgramTemplateCoder.decode(try ProgramTemplateCoder.encode(exported))
        #expect(decoded == exported)

        let original = try ProgramTemplateCoder.decode(Data(templateJSON.utf8))
        #expect(decoded.weeks.map(\.name) == original.expandedWeeks().map(\.name))
        #expect(decoded.weeks[0].days[0].exercises?[0].rest == ProgramTemplate.Rest(min: 120, max: 180))
        #expect(decoded.exercises?.map(\.name) == ["Squat"])
    }
}

@MainActor
struct WorkoutPlannerTests {
    @Test func nextDaySkipsRestDaysAndEndsWithProgram() throws {
        let context = try makeContext()
        let program = try importTestProgram(into: context)
        try WorkoutPlanner.activate(program, in: context)
        program.startedAt = .distantPast

        let days = program.trainingDays
        #expect(WorkoutPlanner.nextDay(in: program)?.persistentModelID == days[0].persistentModelID)

        for (index, day) in days.enumerated() {
            let session = WorkoutPlanner.startSession(for: day, in: context, at: Date(timeIntervalSince1970: Double(index) * 86400))
            WorkoutPlanner.finish(session, in: context, at: session.startedAt.addingTimeInterval(3600))

            let next = WorkoutPlanner.nextDay(in: program)
            if index + 1 < days.count {
                #expect(next?.persistentModelID == days[index + 1].persistentModelID)
            } else {
                #expect(next == nil)
            }
        }

        WorkoutPlanner.restart(program)
        #expect(WorkoutPlanner.nextDay(in: program)?.persistentModelID == days[0].persistentModelID)
    }

    @Test func unfinishedSessionsDoNotAdvanceProgram() throws {
        let context = try makeContext()
        let program = try importTestProgram(into: context)
        try WorkoutPlanner.activate(program, in: context)
        program.startedAt = .distantPast

        let first = try #require(WorkoutPlanner.nextDay(in: program))
        _ = WorkoutPlanner.startSession(for: first, in: context)
        #expect(WorkoutPlanner.nextDay(in: program)?.persistentModelID == first.persistentModelID)
    }

    @Test func activatingDeactivatesOtherPrograms() throws {
        let context = try makeContext()
        let first = try importTestProgram(into: context)
        let second = try importTestProgram(into: context)

        try WorkoutPlanner.activate(first, in: context)
        try WorkoutPlanner.activate(second, in: context)
        #expect(!first.isActive)
        #expect(second.isActive)
        #expect(second.startedAt != nil)
    }

    @Test func sessionUsesPlannedSetsAndPreviousPerformance() throws {
        let context = try makeContext()
        let program = try importTestProgram(into: context)
        let week1 = program.sortedWeeks[0].sortedDays[0]
        let week2 = program.sortedWeeks[1].sortedDays[0]

        let first = WorkoutPlanner.startSession(for: week1, in: context, at: Date(timeIntervalSince1970: 0))
        #expect(first.sortedEntries.map { $0.sets.count } == [3, 2])
        #expect(first.weekName == "Week 1")

        let squat = try #require(first.sortedEntries.first)
        let sets = squat.sortedSets
        sets[0].load = 100; sets[0].reps = 8
        WorkoutPlanner.complete(sets[0], previous: nil)
        sets[1].load = 100; sets[1].reps = 7
        WorkoutPlanner.complete(sets[1], previous: nil)
        WorkoutPlanner.finish(first, in: context, at: Date(timeIntervalSince1970: 3600))

        // The skipped third set and the untouched superset exercise are dropped.
        #expect(squat.sets.count == 2)
        #expect(first.entries.count == 1)

        let second = WorkoutPlanner.startSession(for: week2, in: context, at: Date(timeIntervalSince1970: 86400))
        let secondSquat = try #require(second.sortedEntries.first)
        let previous = WorkoutPlanner.previousSets(for: secondSquat.exercise, before: second)
        #expect(previous.map(\.reps) == [8, 7])

        // Completing an empty set copies what was done last time, beyond the last set falls back to the last one.
        let setsNow = secondSquat.sortedSets
        WorkoutPlanner.complete(setsNow[2], previous: WorkoutPlanner.previousSet(at: 2, in: previous))
        #expect(setsNow[2].load == 100)
        #expect(setsNow[2].reps == 7)
    }

    @Test func swappingClearsIncompleteSets() throws {
        let context = try makeContext()
        let program = try importTestProgram(into: context)
        let day = program.sortedWeeks[0].sortedDays[0]
        let session = WorkoutPlanner.startSession(for: day, in: context)

        let entry = try #require(session.sortedEntries.first)
        let substitution = try #require(entry.planned?.substitutions.first)
        let sets = entry.sortedSets
        sets[0].load = 60; sets[0].reps = 10
        WorkoutPlanner.complete(sets[0], previous: nil)
        sets[1].load = 60

        WorkoutPlanner.swap(entry, to: substitution)
        #expect(entry.exercise?.name == "Leg Press")
        #expect(sets[0].load == 60)
        #expect(sets[1].load == nil)
    }

    @Test func duplicatingWeekCopiesDaysAfterOriginal() throws {
        let context = try makeContext()
        let program = try importTestProgram(into: context)
        let week1 = program.sortedWeeks[0]

        let copy = try #require(ProgramEditing.duplicate(week1))
        #expect(program.sortedWeeks.map(\.name) == ["Week 1", "Week 1 (copy)", "Week 2", "Deload"])
        #expect(copy.sortedDays.map(\.name) == week1.sortedDays.map(\.name))
        #expect(copy.sortedDays[0].sortedExercises.first?.exercise?.name == "Squat")
        #expect(copy.sortedDays[0].sortedExercises.first?.substitutions.map(\.name) == ["Leg Press"])
    }
}

@MainActor
struct WorkoutMathTests {
    @Test func estimatedOneRepMax() {
        #expect(WorkoutMath.estimatedOneRepMax(load: 100, reps: 1) == 100)
        #expect(WorkoutMath.estimatedOneRepMax(load: 100, reps: 0) == nil)
        #expect(abs((WorkoutMath.estimatedOneRepMax(load: 100, reps: 10) ?? 0) - 133.333) < 0.01)
    }

    @Test(arguments: [
        ("~2-3 min", 120, 180),
        ("~0.5-1 min", 30, 60),
        ("1,5 min", 90, 90),
        ("90 s", 90, 90),
        ("45", 45, 45),
    ])
    func parseRest(text: String, min: Int, max: Int) throws {
        let rest = try #require(WorkoutMath.parseRest(text))
        #expect(rest.min == min)
        #expect(rest.max == max)
    }

    @Test func parseRestRejectsEmptyInput() {
        #expect(WorkoutMath.parseRest("") == nil)
        #expect(WorkoutMath.parseRest("n/a") == nil)
    }

    @Test func formatRest() {
        #expect(WorkoutMath.formatRest(min: 120, max: 180) == "2-3 min")
        #expect(WorkoutMath.formatRest(min: 45, max: nil) == "45 s")
        #expect(WorkoutMath.formatRest(min: nil, max: nil) == nil)
    }

    @Test func parseLoad() {
        #expect(WorkoutMath.parseLoad("82.5") == 82.5)
        #expect(WorkoutMath.parseLoad("82,5") == 82.5)
        #expect(WorkoutMath.parseLoad(" ") == nil)
        #expect(WorkoutMath.parseLoad("abc") == nil)
    }

    @Test func nextName() {
        #expect(ProgramEditing.nextName(after: "Week 4", in: ["Week 4"]) == "Week 5")
        #expect(ProgramEditing.nextName(after: "Week 1", in: ["Week 1", "Week 2"]) == "Week 1 (copy)")
        #expect(ProgramEditing.nextName(after: "Deload", in: []) == "Deload (copy)")
    }
}
