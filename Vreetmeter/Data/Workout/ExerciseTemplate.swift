
import Foundation
import SwiftData

@Model
class ExerciseTemplate: Identifiable {
    @Attribute(.unique) let id: UUID
    var workout: WorkoutTemplate?
    @Relationship var exercise: Exercise
    @Relationship var substitutions: [Exercise]
    @Relationship var superset: SupersetTemplate?
    @Relationship(deleteRule: .cascade) var sets: [SetTemplate]
    var sortOrder: Int
    
    init(workout: WorkoutTemplate, exercise: Exercise) {
        self.id = UUID()
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
    let repetitions: Int
    let rpe: RPE
    let intensitiyTechnique: IntensityTechnique
    var sortOrder: Int
    
    init(exercise: ExerciseTemplate, repetitions: Int, rpe: RPE, intensitiyTechnique: IntensityTechnique) {
        self.exercise = exercise
        self.repetitions = repetitions
        self.rpe = rpe
        self.intensitiyTechnique = intensitiyTechnique
        self.sortOrder = exercise.sets.count
    }
    
    struct RPE: Codable {
        let lowerLimit: Int
        let upperLimit: Int
    }
}
