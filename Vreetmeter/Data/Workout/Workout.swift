
import Foundation
import SwiftData

@Model
class Workout {
    @Attribute(.unique) var name: String
    var date: Date
    @Relationship(deleteRule: .cascade, inverse: \ExerciseExecution.workout) var exercises: ExerciseExecution
    
    init(name: String, date: Date, exercises: ExerciseExecution) {
        self.name = name
        self.date = date
        self.exercises = exercises
    }
}
