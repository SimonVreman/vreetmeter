
import SwiftUI

struct WorkoutPlanEditorSheet: View {
    var plan: WorkoutPlan?
    
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    @State private var name = ""
    
    private func save() {
        if let plan {
            plan.name = name
        } else {
            let plan = WorkoutPlan(name: name)
            modelContext.insert(plan)
        }
    }
    
    var body: some View {
        NavigationView {
            Form {
                TextField("Name", text: $name)
            }.onAppear {
                if let plan {
                    name = plan.name
                }
            }.toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        withAnimation {
                            save()
                            dismiss()
                        }
                    }
                }
            }.navigationTitle(plan == nil ? "Add workout plan" : "Edit workout plan")
                .navigationBarTitleDisplayMode(.inline)
        }
    }
}
