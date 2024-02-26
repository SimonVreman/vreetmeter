
import Foundation
import SwiftData

@Model
class ExerciseTemplate {
    var workout: WorkoutTemplate?
    @Relationship var exercise: Exercise
    @Relationship var substitutions: [Exercise]
    @Relationship var superset: SupersetTemplate?
    @Relationship(deleteRule: .cascade) var sets: [SetTemplate]
    var sortOrder: Int
    
    init(workout: WorkoutTemplate, exercise: Exercise) {
        self.workout = workout
        self.exercise = exercise
        self.substitutions = []
        self.sets = []
        self.sortOrder = workout.exercises.count
    }
}

@Model
class SetTemplate {
    var exercise: ExerciseTemplate?
    var repetitionRange: RepetitionRange
    var rpe: RPE?
    var intensitiyTechnique: IntensityTechnique?
    var sortOrder: Int
    
    init(exercise: ExerciseTemplate) {
        self.exercise = exercise
        self.repetitionRange = RepetitionRange()
        self.sortOrder = exercise.sets.count
    }
    
    struct RPE: Codable {
        let lowerLimit: Int
        let upperLimit: Int
    }
    
    struct RepetitionRange: Codable {
        var lowerLimit: Int?
        var upperLimit: Int?
    }
}
