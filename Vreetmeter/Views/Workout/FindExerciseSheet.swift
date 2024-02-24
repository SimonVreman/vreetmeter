
import SwiftUI
import SwiftData

struct FindExerciseSheet: View {
    var workoutTemplate: WorkoutTemplate?
    var exerciseTemplate: ExerciseTemplate?
    
    @Environment(\.dismiss) var dismiss
    @State private var selection = Set<Exercise>()
    
    @Query
    private var exercises: [Exercise]
    
    private func addExercices(_ exercises: any Sequence<Exercise>) {
        workoutTemplate?.exercises.append(contentsOf: exercises.map {
            ExerciseTemplate(exercise: $0, substitutions: [], sets: [])
        })
        exerciseTemplate?.substitutions.append(contentsOf: exercises)
    }
    
    var body: some View {
        List(exercises, selection: $selection) { exercise in
            Text(exercise.name)
        }.toolbar {
            Button("Add") {
                addExercices(exercises)
                dismiss()
            }
        }
    }
}
