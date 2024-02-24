
import Foundation
import SwiftData

class WorkoutPlan: Identifiable, Hashable {
    @Attribute(.unique) var id: UUID
    @Attribute(.unique) var name: String
    @Relationship var workouts: [Int:WorkoutTemplate]
    
    init(name: String, workouts: [Int:WorkoutTemplate]) {
        self.id = UUID()
        self.name = name
        self.workouts = workouts
    }
}
