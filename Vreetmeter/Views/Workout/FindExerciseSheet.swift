
import SwiftUI
import SwiftData

struct FindExerciseSheet: View {
    var workoutTemplate: WorkoutTemplate?
    var exerciseTemplate: ExerciseTemplate?
    
    @Environment(\.dismiss) var dismiss
    @Environment(\.modelContext) private var modelContext
    @State private var selection = Set<Exercise>()
    
    @Query
    private var exercises: [Exercise]
    
    private func addExercices(_ exercises: any Sequence<Exercise>) {
        if let workoutTemplate { exercises.forEach { modelContext.insert(
            ExerciseTemplate(
                workout: workoutTemplate,
                exercise: $0,
                sortOrder: workoutTemplate.exercises.count
            )
        )}}
        if let exerciseTemplate {
            exerciseTemplate.substitutions.append(contentsOf: exercises)
        }
    }
    
    var body: some View {
        NavigationView {
            List(exercises, selection: $selection) { exercise in
                Text(exercise.name)
            }.toolbar {
                Button("Add") {
                    addExercices(exercises)
                    dismiss()
                }.disabled(selection.isEmpty)
            }.navigationTitle("Find exercise")
                .navigationBarTitleDisplayMode(.inline)
        }
    }
}
