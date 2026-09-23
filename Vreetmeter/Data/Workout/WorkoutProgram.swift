import Foundation
import SwiftData

@Model
final class WorkoutProgram {
    var name: String = ""
    var notes: String?
    var createdAt: Date = Date.now
    var isActive: Bool = false
    /// Sessions started before this date do not count towards the program's progress, used to restart a program.
    var startedAt: Date?

    @Relationship(deleteRule: .cascade, inverse: \ProgramWeek.program)
    var weeks: [ProgramWeek] = []

    init(name: String, notes: String? = nil) {
        self.name = name
        self.notes = notes
    }

    var sortedWeeks: [ProgramWeek] {
        weeks.sorted { $0.sortOrder < $1.sortOrder }
    }

    /// All training days of the program in the order they should be performed.
    var trainingDays: [ProgramDay] {
        sortedWeeks.flatMap { $0.sortedDays.filter { $0.kind == .training } }
    }
}

@Model
final class ProgramWeek {
    var program: WorkoutProgram?
    var sortOrder: Int = 0
    var name: String = ""
    var block: String?
    var note: String?

    @Relationship(deleteRule: .cascade, inverse: \ProgramDay.week)
    var days: [ProgramDay] = []

    init(name: String, sortOrder: Int, block: String? = nil, note: String? = nil) {
        self.name = name
        self.sortOrder = sortOrder
        self.block = block
        self.note = note
    }

    var sortedDays: [ProgramDay] {
        days.sorted { $0.sortOrder < $1.sortOrder }
    }
}

nonisolated enum ProgramDayKind: String, Codable, CaseIterable {
    case training
    case optionalRest
    case rest

    var label: String {
        switch self {
        case .training: "Training"
        case .optionalRest: "Optional rest day"
        case .rest: "Rest day"
        }
    }
}

@Model
final class ProgramDay {
    var week: ProgramWeek?
    var sortOrder: Int = 0
    var name: String = ""
    var kind: ProgramDayKind = ProgramDayKind.training

    @Relationship(deleteRule: .cascade, inverse: \PlannedExercise.day)
    var exercises: [PlannedExercise] = []

    @Relationship(deleteRule: .nullify, inverse: \WorkoutSession.programDay)
    var sessions: [WorkoutSession] = []

    init(name: String, sortOrder: Int, kind: ProgramDayKind = .training) {
        self.name = name
        self.sortOrder = sortOrder
        self.kind = kind
    }

    var sortedExercises: [PlannedExercise] {
        exercises.sorted { $0.sortOrder < $1.sortOrder }
    }
}

@Model
final class PlannedExercise {
    var day: ProgramDay?
    var sortOrder: Int = 0
    var exercise: Exercise?
    var substitutions: [Exercise] = []
    /// Exercises sharing a group label (e.g. "A") are performed as a superset.
    var supersetGroup: String?
    var warmupSets: String = ""
    var workingSets: Int = 3
    /// Free-form target such as "8-10", "4, 6, 8" or "5,4,3+".
    var repTarget: String = ""
    var earlyRPE: String?
    var lastRPE: String?
    var restMinSeconds: Int?
    var restMaxSeconds: Int?
    var intensityTechnique: String?
    var notes: String?

    @Relationship(deleteRule: .nullify, inverse: \LoggedExercise.planned)
    var loggedExercises: [LoggedExercise] = []

    init(sortOrder: Int) {
        self.sortOrder = sortOrder
    }

    var restDescription: String? {
        WorkoutMath.formatRest(min: restMinSeconds, max: restMaxSeconds)
    }

    /// Short summary of the working sets, e.g. "3 × 8-10 · RPE ~9 / 10".
    var targetDescription: String {
        var parts = ["\(workingSets) × \(repTarget.isEmpty ? "?" : repTarget)"]
        switch (earlyRPE, lastRPE) {
        case let (early?, last?) where !early.isEmpty && !last.isEmpty: parts.append("RPE \(early) / \(last)")
        case let (early?, _) where !early.isEmpty: parts.append("RPE \(early)")
        case let (_, last?) where !last.isEmpty: parts.append("RPE \(last)")
        default: break
        }
        return parts.joined(separator: " · ")
    }
}
