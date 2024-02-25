
import SwiftUI

struct ExerciseEditorSheet: View {
    var exercise: Exercise?
    
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    
    @State private var name = ""
    
    private var isValid: Bool {
        !name.isEmpty
    }
    
    private func fillFromModel() {
        if let exercise {
            name = exercise.name
        }
    }
    
    private func save() {
        if let exercise {
            exercise.name = name
        } else {
            let exercise = Exercise(name: name)
            modelContext.insert(exercise)
        }
    }
    
    var body: some View {
        WorkoutEditorSheet(
            title: exercise == nil ? "Add exercise" : "Edit exercise",
            onSave: save,
            isValid: isValid,
            content: {
                TextField("Name", text: $name)
            }
        ).onAppear(perform: fillFromModel)
    }
}
