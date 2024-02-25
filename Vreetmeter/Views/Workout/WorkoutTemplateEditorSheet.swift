
import SwiftUI

struct WorkoutTemplateEditorSheet: View {
    var plan: WorkoutPlan
    var template: WorkoutTemplate?
    
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext

    @State private var name = ""
    
    private var isValid: Bool {
        !name.isEmpty
    }
    
    private func fillFromModel() {
        if let template {
            name = template.name
        }
    }
    
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
        WorkoutEditorSheet(
            title: template == nil ? "Add workout" : "Edit workout",
            onSave: save,
            isValid: isValid,
            content: {
                TextField("Name", text: $name)
            }
        ).onAppear(perform: fillFromModel)
    }
}
