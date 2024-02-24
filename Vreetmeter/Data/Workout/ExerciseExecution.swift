
import Foundation
import SwiftData

class ExerciseExecution {
    @Relationship var workout: Workout
    @Relationship var template: ExerciseTemplate
    var sets: [Int:SetExecution]
    
    init(workout: Workout, template: ExerciseTemplate, sets: [Int:SetExecution]) {
        self.workout = workout
        self.template = template
        self.sets = sets
    }
    
    struct SetExecution {
        var repetitions: Int
        var load: Double
    }
}
