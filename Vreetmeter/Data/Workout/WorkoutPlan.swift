
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
    var plan: WorkoutPlan?
    @Relationship(deleteRule: .cascade, inverse: \WorkoutTemplate.day) var workout: WorkoutTemplate?
    var sortOrder: Int
    
    init(plan: WorkoutPlan) {
        self.plan = plan
        self.sortOrder = plan.days.count
    }
}
