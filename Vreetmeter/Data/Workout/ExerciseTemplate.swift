
import Foundation
import SwiftData

@Model
class ExerciseTemplate: Identifiable, Hashable {
    @Attribute(.unique) var id: UUID
    @Relationship var workout: WorkoutTemplate
    @Relationship var exercise: Exercise
    @Relationship var substitutions: [Exercise]
    var sets: [SetTemplate]
    
    init(exercise: Exercise, substitutions: [Exercise], sets: [SetTemplate]) {
        self.id = UUID()
        self.exercise = exercise
        self.substitutions = substitutions
        self.sets = sets
    }
    
    struct SetTemplate {
        let repetitions: Int
        let rpe: RPE
        let intensitiyTechnique: IntensityTechnique
        
        struct RPE {
            let lowerLimit: Int
            let upperLimit: Int
        }
    }
}
