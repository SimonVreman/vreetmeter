
import Foundation
import SwiftData

@Model
class WorkoutPlan: Identifiable {
    @Attribute(.unique) let id: UUID
    @Attribute(.unique) var name: String
    @Relationship(deleteRule: .cascade, inverse: \WorkoutTemplate.plan) var workouts: [WorkoutTemplate]
    var restDays: [Int]
    
    init(name: String) {
        self.id = UUID()
        self.name = name
        self.workouts = []
        self.restDays = []
    }
}
