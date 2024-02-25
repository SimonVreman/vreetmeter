
import Foundation
import SwiftData

@Model
class WorkoutPlan {
    @Attribute(.unique) var name: String
    @Relationship(deleteRule: .cascade, inverse: \WorkoutPlanDay.plan) var days: [WorkoutPlanDay]
    
    init(name: String) {
        self.name = name
        self.days = []
    }
}

@Model
class WorkoutPlanDay {
    @Relationship(deleteRule: .cascade, inverse: \WorkoutTemplate.day) var workout: WorkoutTemplate?
    var plan: WorkoutPlan?
    var sortOrder: Int
    
    init(plan: WorkoutPlan) {
        self.plan = plan
        self.sortOrder = plan.days.count
    }
}
