
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
            let day = WorkoutPlanDay(plan: plan)
            plan.days.append(day)

            let template = WorkoutTemplate(day: day, name: name, exercises: [])
            day.workout = template
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
