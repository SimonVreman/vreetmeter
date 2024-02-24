
import SwiftUI
import SwiftData

struct FindWorkoutTemplateSheet: View {
    var plan: WorkoutPlan
    
    @Environment(\.dismiss) var dismiss
    
    @Query
    private var templates: [WorkoutTemplate]
    
    private func addWorkout(_ template: WorkoutTemplate) {
        plan.workouts.append(template)
    }
    
    var body: some View {
        List(templates) { template in
            Button(template.name) {
                addWorkout(template)
                dismiss()
            }
        }
    }
}
