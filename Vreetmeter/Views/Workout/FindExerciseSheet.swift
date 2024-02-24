
import SwiftUI
import SwiftData

struct FindExerciseSheet: View {
    var workoutTemplate: WorkoutTemplate?
    var exerciseTemplate: ExerciseTemplate?
    
    @Environment(\.dismiss) var dismiss
    @Environment(\.modelContext) private var modelContext
    @State private var selection = Set<UUID>()
    @State private var showEditorSheet = false
    
    @Query
    private var exercises: [Exercise]
    
    private func addExercices(_ exerciseIds: Set<UUID>) {
        let exercises = self.exercises.filter { exerciseIds.contains($0.id) }
        if let workoutTemplate { exercises.forEach {
            let exercise = ExerciseTemplate(
                workout: workoutTemplate,
                exercise: $0,
                sortOrder: workoutTemplate.exercises.count
            )
            workoutTemplate.exercises.append(exercise)
        }}
        if let exerciseTemplate {
            exerciseTemplate.substitutions.append(contentsOf: exercises)
        }
    }
    
    var body: some View {
        NavigationView {
            VStack {
                if exercises.isEmpty {
                    emptyView
                } else {
                    exercisesView
                }
            }.navigationTitle("Find exercise")
                .navigationBarTitleDisplayMode(.inline)
        }.sheet(isPresented: $showEditorSheet) {
            ExerciseEditorSheet()
        }
    }
    
    private var exercisesView: some View {
        List(exercises, selection: $selection) { exercise in
            Text(exercise.name)
        }.toolbar {
            ToolbarItem(placement: .secondaryAction) {
                Button("New") {
                    showEditorSheet = true
                }
            }
            ToolbarItem(placement: .confirmationAction) {
                Button("Add") {
                    addExercices(selection)
                    dismiss()
                }.disabled(selection.isEmpty)
            }
        }.environment(\.editMode, .constant(EditMode.active))
    }
    
    private var emptyView: some View {
        ContentUnavailableView {
            Label("No exercises", systemImage: "figure.core.training")
        } description: {
            Text("You have not created any exercises yet, create one now!")
        } actions: {
            Button {
                showEditorSheet = true
            } label: {
                Text("Add exercises")
            }.buttonStyle(.borderedProminent)
                .controlSize(.regular)
        }
    }
}
