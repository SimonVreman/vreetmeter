
import Foundation
import SwiftData

@Model
class SupersetTemplate {
    @Relationship(inverse: \ExerciseTemplate.superset) var exercises: [ExerciseTemplate]
    
    init(exercises: [ExerciseTemplate]) {
        self.exercises = exercises
    }
}
