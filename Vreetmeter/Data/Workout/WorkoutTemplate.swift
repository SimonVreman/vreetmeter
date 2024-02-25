
import Foundation
import SwiftData

@Model
class WorkoutTemplate {
    var day: WorkoutPlanDay?
    @Attribute(.unique) var name: String
    @Relationship(deleteRule: .cascade, inverse: \ExerciseTemplate.workout) var exercises: [ExerciseTemplate]
    
    init(day: WorkoutPlanDay, name: String, exercises: [ExerciseTemplate]) {
        self.day = day
        self.name = name
        self.exercises = exercises
    }
}
