
import SwiftUI
import SwiftData

struct FindExerciseSheet: View {
    var workoutTemplate: WorkoutTemplate?
    var exerciseTemplate: ExerciseTemplate?
    
    @Environment(\.dismiss) var dismiss
    @Environment(\.modelContext) private var modelContext
    
    @State private var selection = Set<PersistentIdentifier>()
    @State private var showEditorSheet = false
    
    @Query private var exercises: [Exercise]
    
    private func addExercices(_ exerciseIds: Set<PersistentIdentifier>) {
        let exercises = self.exercises.filter { exerciseIds.contains($0.id) }
        if let workoutTemplate { exercises.forEach {
            let exercise = ExerciseTemplate(
                workout: workoutTemplate,
                exercise: $0
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
        VStack(spacing: 0) {
            List(exercises, selection: $selection) { exercise in
                Text(exercise.name)
            }.environment(\.editMode, .constant(EditMode.active))
                .listStyle(.grouped)
            
            Spacer(minLength: 0)
            Divider()
            
            Button("Add") {
                addExercices(selection)
                dismiss()
            }.buttonStyle(ActionButtonStyle(disabled: selection.isEmpty))
                .disabled(selection.isEmpty)
        }.toolbar {
            ToolbarItem(placement: .primaryAction) {
                Button("New") {
                    showEditorSheet = true
                }
            }
        }
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
