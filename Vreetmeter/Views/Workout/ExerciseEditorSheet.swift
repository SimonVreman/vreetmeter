
import SwiftUI

struct ExerciseEditorSheet: View {
    var exercise: Exercise?
    
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    @State private var name = ""
    
    private func save() {
        if let exercise {
            exercise.name = name
        } else {
            let exercise = Exercise(name: name)
            modelContext.insert(exercise)
        }
    }
    
    var body: some View {
        NavigationView {
            Form {
                TextField("Name", text: $name)
            }.onAppear {
                if let exercise {
                    name = exercise.name
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
            }.navigationTitle(exercise == nil ? "Add exercise" : "Edit exercise")
                .navigationBarTitleDisplayMode(.inline)
        }
    }
}
