
import Foundation
import SwiftData

@Model
class WorkoutPlan: Identifiable {
    @Attribute(.unique) let id: UUID
    @Attribute(.unique) var name: String
    @Relationship var workouts: [WorkoutTemplate]
    var restDays: [Int]
    
    init(name: String, workouts: [WorkoutTemplate], restDays: [Int]) {
        self.id = UUID()
        self.name = name
        self.workouts = workouts
        self.restDays = restDays
    }
}
