
import SwiftUI

struct WorkoutTemplateEditorSheet: View {
    var plan: WorkoutPlan
    var template: WorkoutTemplate?
    
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    @State private var name = ""
    
    private func save() {
        if let template {
            template.name = name
        } else {
            let template = WorkoutTemplate(plan: plan, name: name, exercises: [], sortOrder: plan.workouts.count)
            plan.workouts.append(template)
        }
    }
    
    var body: some View {
        NavigationView {
            Form {
                TextField("Name", text: $name)
            }.onAppear {
                if let template {
                    name = template.name
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
            }.navigationTitle(template == nil ? "Add workout" : "Edit workout")
                .navigationBarTitleDisplayMode(.inline)
        }
    }
}
