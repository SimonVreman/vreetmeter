
import SwiftUI

struct WorkoutTemplateView: View {
    var template: WorkoutTemplate
    
    @State private var showEditorSheet = false
    
    var body: some View {
        VStack {
            if template.exercises.isEmpty {
                emptyView
            } else {
                exercisesView
            }
        }.sheet(isPresented: $showEditorSheet) {
            FindExerciseSheet(workoutTemplate: template)
        }.navigationTitle(template.name)
    }
    
    private var exercisesView: some View {
        List(template.exercises.sorted { a, b in a.sortOrder < b.sortOrder }) { exercise in
            NavigationLink(exercise.exercise.name, destination: ExerciseTemplateView(template: exercise))
        }.toolbar {
            Button("Add") {
                showEditorSheet = true
            }
        }
    }
    
    private var emptyView: some View {
        ContentUnavailableView {
            Label("No exercises added", systemImage: "figure.strengthtraining.traditional")
        } description: {
            Text("You haven't added any exercises yet, pick some now!")
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
