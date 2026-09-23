import Foundation
import SwiftData

@Model
final class Exercise {
    var name: String = ""
    var instructions: String?
    var videoURL: String?

    @Relationship(deleteRule: .nullify, inverse: \PlannedExercise.exercise)
    var plannedExercises: [PlannedExercise] = []

    @Relationship(deleteRule: .nullify, inverse: \PlannedExercise.substitutions)
    var substituteFor: [PlannedExercise] = []

    @Relationship(deleteRule: .nullify, inverse: \LoggedExercise.exercise)
    var loggedExercises: [LoggedExercise] = []

    init(name: String, instructions: String? = nil, videoURL: String? = nil) {
        self.name = name
        self.instructions = instructions
        self.videoURL = videoURL
    }

    /// Logged entries of finished sessions, most recent first.
    var history: [LoggedExercise] {
        loggedExercises
            .filter { $0.session?.isFinished == true }
            .sorted { ($0.session?.startedAt ?? .distantPast) > ($1.session?.startedAt ?? .distantPast) }
    }

    static func normalizedName(_ name: String) -> String {
        name.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
    }

    /// Finds an exercise by case-insensitive name, creating it when it does not exist yet.
    static func findOrCreate(named name: String, in context: ModelContext, cache: inout [String: Exercise]) throws -> Exercise {
        if cache.isEmpty {
            for exercise in try context.fetch(FetchDescriptor<Exercise>()) {
                cache[normalizedName(exercise.name)] = exercise
            }
        }

        let key = normalizedName(name)
        if let existing = cache[key] { return existing }

        let exercise = Exercise(name: name.trimmingCharacters(in: .whitespacesAndNewlines))
        context.insert(exercise)
        cache[key] = exercise
        return exercise
    }
}
