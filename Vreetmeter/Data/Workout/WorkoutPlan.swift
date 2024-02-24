
import Foundation
import SwiftData

class WorkoutPlan {
    @Attribute(.unique) var name: String
    @Relationship var workouts: [Int:WorkoutTemplate]
    
    init(name: String, workouts: [Int:WorkoutTemplate]) {
        self.name = name
        self.workouts = workouts
    }
}
