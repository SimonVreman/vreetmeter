
import SwiftUI
import SwiftData

struct WorkoutTemplateView: View {
    var template: WorkoutTemplate
    
    @Environment(\.modelContext) private var modelContext
    
    @State private var showEditorSheet = false
    
    @Query private var exercisesQuery: [ExerciseTemplate]
    
    private var exercises: [ExerciseTemplate] {
        exercisesQuery.filter { $0.workout == template } .sorted { a, b in a.sortOrder < b.sortOrder }
    }
    
    private func onDelete(at offsets: IndexSet) {
        for index in offsets {
            modelContext.delete(exercises[index])
        }
        updateSortOrder(basedOn: exercises)
    }
    
    private func onMove(fromOffsets source: IndexSet, toOffset destination: Int) {
        var copy = exercises
        copy.move(fromOffsets: source, toOffset: destination)
        updateSortOrder(basedOn: copy)
    }
    
    private func updateSortOrder(basedOn order: [ExerciseTemplate]) {
        for (index, day) in order.enumerated() {
            day.sortOrder = index
        }
    }
    
    var body: some View {
        VStack {
            if exercises.isEmpty {
                emptyView
            } else {
                exercisesView
            }
        }.sheet(isPresented: $showEditorSheet) {
            FindExerciseSheet(workoutTemplate: template)
        }.navigationTitle(template.name)
    }
    
    private var exercisesView: some View {
        VStack(spacing: 0) {
            List {
                ForEach(exercises) { exercise in
                    NavigationLink(exercise.exercise.name, destination: ExerciseTemplateView(template: exercise))
                }.onDelete(perform: onDelete)
                    .onMove(perform: onMove)
            }.listStyle(.grouped)
            
            Spacer(minLength: 0)
            Divider()
            
            HStack(spacing: 0) {
                Button("Add exercise", systemImage: "plus") {
                    showEditorSheet = true
                }.padding(16)
                    .frame(minWidth: 0, maxWidth: .infinity)
            }
        }.toolbar {
            EditButton()
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
