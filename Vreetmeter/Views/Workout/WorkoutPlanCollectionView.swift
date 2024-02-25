
import SwiftUI
import SwiftData

struct WorkoutPlanCollectionView: View {
    @Query(sort: \WorkoutPlan.name)
    private var plans: [WorkoutPlan]
    
    @State private var showEditorSheet = false
    
    var body: some View {
        VStack {
            if plans.isEmpty {
                emptyView
            } else {
                plansView
            }
        }.sheet(isPresented: $showEditorSheet) {
            WorkoutPlanEditorSheet()
        }
    }
    
    private var plansView: some View {
        List(plans) { plan in
            NavigationLink(plan.name, destination: WorkoutPlanView(plan: plan))
        }.toolbar {
            Button("Add") {
                showEditorSheet = true
            }
        }
    }
    
    private var emptyView: some View {
        ContentUnavailableView {
            Label("No workout plans", systemImage: "tray.2.fill")
        } description: {
            Text("You don't have any workout plans yet, create one now!")
        } actions: {
            Button {
                showEditorSheet = true
            } label: {
                Text("Add workout plan")
            }.buttonStyle(.borderedProminent)
                .controlSize(.regular)
        }
    }
}
