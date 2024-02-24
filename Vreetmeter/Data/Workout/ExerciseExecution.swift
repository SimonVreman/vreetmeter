
import Foundation
import SwiftData

@Model
class ExerciseExecution {
    @Relationship var workout: Workout
    @Relationship var template: ExerciseTemplate
    var sets: [Int:SetExecution]
    
    init(workout: Workout, template: ExerciseTemplate, sets: [Int:SetExecution]) {
        self.workout = workout
        self.template = template
        self.sets = sets
    }
    
    struct SetExecution: Codable {
        var repetitions: Int
        var load: Double
    }
}
