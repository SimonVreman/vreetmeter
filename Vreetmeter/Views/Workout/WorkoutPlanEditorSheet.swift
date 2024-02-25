
import SwiftUI

struct WorkoutPlanEditorSheet: View {
    var plan: WorkoutPlan?
    
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    
    @State private var name = ""
    
    private var isValid: Bool {
        !name.isEmpty
    }
    
    private func fillFromModel() {
        if let plan {
            name = plan.name
        }
    }
    
    private func save() {
        if let plan {
            plan.name = name
        } else {
            let plan = WorkoutPlan(name: name)
            modelContext.insert(plan)
        }
    }
    
    var body: some View {
        WorkoutEditorSheet(
            title: plan == nil ? "Add workout plan" : "Edit workout plan",
            onSave: save,
            isValid: isValid,
            content: {
                TextField("Name", text: $name)
            }
        ).onAppear(perform: fillFromModel)
    }
}
