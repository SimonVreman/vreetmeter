import Foundation
import SwiftData

@Model
final class WorkoutSession {
    var uuid: UUID = UUID()
    var startedAt: Date = Date.now
    var endedAt: Date?
    var programDay: ProgramDay?
    /// Snapshot of the day and week names, so history stays readable when the program changes.
    var title: String = ""
    var weekName: String?
    var healthKitWorkoutID: UUID?

    @Relationship(deleteRule: .cascade, inverse: \LoggedExercise.session)
    var entries: [LoggedExercise] = []

    init(title: String, weekName: String? = nil, startedAt: Date = .now) {
        self.title = title
        self.weekName = weekName
        self.startedAt = startedAt
    }

    var isFinished: Bool { endedAt != nil }

    var sortedEntries: [LoggedExercise] {
        entries.sorted { $0.sortOrder < $1.sortOrder }
    }

    var completedSetCount: Int {
        entries.reduce(0) { $0 + $1.completedSets.count }
    }

    var volume: Double {
        entries.reduce(0) { $0 + $1.volume }
    }
}

@Model
final class LoggedExercise {
    var session: WorkoutSession?
    var sortOrder: Int = 0
    /// The exercise actually performed, which may be a substitution of the planned exercise.
    var exercise: Exercise?
    var planned: PlannedExercise?

    @Relationship(deleteRule: .cascade, inverse: \LoggedSet.entry)
    var sets: [LoggedSet] = []

    init(sortOrder: Int) {
        self.sortOrder = sortOrder
    }

    var sortedSets: [LoggedSet] {
        sets.sorted { $0.sortOrder < $1.sortOrder }
    }

    var completedSets: [LoggedSet] {
        sortedSets.filter { $0.isCompleted }
    }

    var volume: Double {
        completedSets.reduce(0) { $0 + ($1.load ?? 0) * Double($1.reps ?? 0) }
    }

    /// The completed set with the highest estimated one-rep max.
    var bestSet: LoggedSet? {
        completedSets.max { ($0.estimatedOneRepMax ?? 0) < ($1.estimatedOneRepMax ?? 0) }
    }
}

@Model
final class LoggedSet {
    var entry: LoggedExercise?
    var sortOrder: Int = 0
    /// Load in kilograms.
    var load: Double?
    var reps: Int?
    var completedAt: Date?

    init(sortOrder: Int, load: Double? = nil, reps: Int? = nil) {
        self.sortOrder = sortOrder
        self.load = load
        self.reps = reps
    }

    var isCompleted: Bool { completedAt != nil }

    var estimatedOneRepMax: Double? {
        guard let load, let reps else { return nil }
        return WorkoutMath.estimatedOneRepMax(load: load, reps: reps)
    }

    var summary: String {
        "\(WorkoutMath.formatLoad(load)) kg × \(reps.map(String.init) ?? "–")"
    }
}
