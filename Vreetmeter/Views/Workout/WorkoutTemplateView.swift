
import SwiftUI

struct WorkoutTemplateView: View {
    var template: WorkoutTemplate
    
    var body: some View {
        List(template.exercises) { exercise in
            NavigationLink(exercise.exercise.name, value: exercise)
        }.navigationTitle(template.name)
    }
}
