
import Foundation
import SwiftData

@Model
class WorkoutTemplate: Identifiable {
    @Attribute(.unique) let id: UUID
    @Attribute(.unique) var name: String
    @Relationship(deleteRule: .cascade, inverse: \ExerciseTemplate.workout) var exercises: [ExerciseTemplate]
    
    init(name: String, exercises: [ExerciseTemplate]) {
        self.id = UUID()
        self.name = name
        self.exercises = exercises
    }
}
