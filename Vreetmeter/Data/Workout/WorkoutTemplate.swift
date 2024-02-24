
import Foundation
import SwiftData

@Model
class WorkoutTemplate: Identifiable {
    @Attribute(.unique) let id: UUID
    var plan: WorkoutPlan?
    @Attribute(.unique) var name: String
    @Relationship(deleteRule: .cascade, inverse: \ExerciseTemplate.workout) var exercises: [ExerciseTemplate]
    var sortOrder: Int
    
    init(plan: WorkoutPlan, name: String, exercises: [ExerciseTemplate], sortOrder: Int) {
        self.id = UUID()
        self.plan = plan
        self.name = name
        self.exercises = exercises
        self.sortOrder = sortOrder
    }
}
