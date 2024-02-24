
import Foundation
import SwiftData

@Model
class WorkoutTemplate {
    @Attribute(.unique) var name: String
    @Relationship(deleteRule: .cascade, inverse: \ExerciseTemplate.workout) var exercises: [ExerciseTemplate]
    
    init(name: String, exercises: [ExerciseTemplate]) {
        self.name = name
        self.exercises = exercises
    }
}
