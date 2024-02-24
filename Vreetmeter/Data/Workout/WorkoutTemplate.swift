
import Foundation
import SwiftData

@Model
class WorkoutTemplate: Identifiable, Hashable {
    @Attribute(.unique) var id: UUID
    @Attribute(.unique) var name: String
    @Relationship(deleteRule: .cascade, inverse: \ExerciseTemplate.workout) var exercises: [ExerciseTemplate]
    
    init(name: String, exercises: [ExerciseTemplate]) {
        self.name = name
        self.exercises = exercises
    }
}
