
import Foundation
import SwiftData

@Model
class SupersetTemplate: Identifiable {
    @Attribute(.unique) let id: UUID
    @Relationship(inverse: \ExerciseTemplate.superset) var exercises: [ExerciseTemplate]
    
    init(exercises: [ExerciseTemplate]) {
        self.id = UUID()
        self.exercises = exercises
    }
}
