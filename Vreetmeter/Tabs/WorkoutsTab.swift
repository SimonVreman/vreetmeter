
import SwiftUI
import SwiftData

struct WorkoutsTab: View {
    @Query private var workoutPlans: [WorkoutPlan]
    
    @State private var showWorkoutPlanEditorSheet = false
    
    var body: some View {
        NavigationStack {
            VStack {
                List(workoutPlans) { plan in
                    NavigationLink(plan.name, value: plan)
                }.navigationDestination(for: WorkoutPlan.self) {
                    WorkoutPlanView(plan: $0)
                }.navigationDestination(for: WorkoutTemplate.self) {
                    WorkoutTemplateView(template: $0)
                }.navigationDestination(for: ExerciseTemplate.self) {
                    ExerciseTemplateView(template: $0)
                }
                
                List {
                    Button("Add workout plan") {
                        showWorkoutPlanEditorSheet = true
                    }
                }
            }.sheet(isPresented: $showWorkoutPlanEditorSheet) {
                WorkoutPlanEditorSheet()
            }
        }
    }
}
