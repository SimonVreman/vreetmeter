import Foundation

/// Portable JSON representation of a workout program, see docs/workout-template.md.
nonisolated struct ProgramTemplate: Codable, Equatable {
    static let currentSchemaVersion = 1

    var schemaVersion: Int
    var name: String
    var notes: String?
    var exercises: [ExerciseInfo]?
    var weeks: [Week]

    struct ExerciseInfo: Codable, Equatable {
        var name: String
        var instructions: String?
        var videoURL: String?
    }

    struct Week: Codable, Equatable {
        var name: String
        var block: String?
        var note: String?
        /// Number of consecutive weeks this definition expands to, defaults to 1.
        var repeatCount: Int?
        var days: [Day]

        enum CodingKeys: String, CodingKey {
            case name, block, note, days
            case repeatCount = "repeat"
        }
    }

    struct Day: Codable, Equatable {
        var name: String
        var kind: ProgramDayKind?
        var exercises: [Exercise]?
    }

    struct Exercise: Codable, Equatable {
        var exercise: String
        var substitutions: [String]?
        var superset: String?
        var warmupSets: String?
        var sets: Int
        var reps: String
        var earlyRPE: String?
        var lastRPE: String?
        var rest: Rest?
        var technique: String?
        var notes: String?
    }

    /// Rest between sets in seconds.
    struct Rest: Codable, Equatable {
        var min: Int
        var max: Int?
    }

    /// Weeks with `repeat` expanded, replacing `{n}` in names with the week number within the program.
    func expandedWeeks() -> [Week] {
        var result: [Week] = []
        for week in weeks {
            for _ in 0..<Swift.max(week.repeatCount ?? 1, 1) {
                var copy = week
                copy.repeatCount = nil
                copy.name = week.name.replacingOccurrences(of: "{n}", with: String(result.count + 1))
                result.append(copy)
            }
        }
        return result
    }
}
