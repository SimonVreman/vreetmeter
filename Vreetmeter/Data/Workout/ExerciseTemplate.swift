
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
    
    init(workout: WorkoutTemplate, exercise: Exercise, sortOrder: Int) {
        self.id = UUID()
        self.workout = workout
        self.exercise = exercise
        self.substitutions = []
        self.sets = []
        self.sortOrder = sortOrder
    }
}

@Model
class SetTemplate {
    let repetitions: Int
    let rpe: RPE
    let intensitiyTechnique: IntensityTechnique
    var sortOrder: Int
    
    init(repetitions: Int, rpe: RPE, intensitiyTechnique: IntensityTechnique, sortOrder: Int) {
        self.repetitions = repetitions
        self.rpe = rpe
        self.intensitiyTechnique = intensitiyTechnique
        self.sortOrder = sortOrder
    }
    
    struct RPE: Codable {
        let lowerLimit: Int
        let upperLimit: Int
    }
}
