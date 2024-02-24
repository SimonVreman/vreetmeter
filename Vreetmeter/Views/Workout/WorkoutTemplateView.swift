
import SwiftUI

struct WorkoutTemplateView: View {
    var template: WorkoutTemplate
    
    @State private var showFindExerciseSheet = false
    
    var body: some View {
        VStack {
            List(template.exercises.sorted { a, b in a.sortOrder < b.sortOrder }) { exercise in
                NavigationLink(exercise.exercise.name, value: exercise)
            }
            
            List {
                Button("Add exercise") { showFindExerciseSheet = true }
            }
        }.sheet(isPresented: $showFindExerciseSheet) {
            FindExerciseSheet(workoutTemplate: template)
        }.navigationTitle(template.name)
    }
}
