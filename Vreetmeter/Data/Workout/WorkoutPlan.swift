
import Foundation
import SwiftData

@Model
class WorkoutPlan: Identifiable {
    @Attribute(.unique) let id: UUID
    @Attribute(.unique) var name: String
    @Relationship(deleteRule: .cascade, inverse: \WorkoutPlanDay.plan) var days: [WorkoutPlanDay]
    
    init(name: String) {
        self.id = UUID()
        self.name = name
        self.days = []
    }
}

@Model
class WorkoutPlanDay: Identifiable {
    @Attribute(.unique) let id: UUID
    @Relationship(deleteRule: .cascade, inverse: \WorkoutTemplate.day) var workout: WorkoutTemplate?
    var plan: WorkoutPlan?
    var sortOrder: Int
    
    init(plan: WorkoutPlan) {
        self.id = UUID()
        self.plan = plan
        self.sortOrder = plan.days.count
    }
}
