
import SwiftUI

struct WorkoutEditorSheet<Content: View>: View {
    let title: String
    let onSave: () -> Void
    let isValid: Bool
    @ViewBuilder let content: Content
    
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                List {
                    content
                }.listStyle(.grouped)
                Divider()
                Button("Save") {
                    onSave()
                    dismiss()
                }.buttonStyle(ActionButtonStyle(disabled: !isValid))
                    .disabled(!isValid)
            }.navigationTitle(title)
                .navigationBarTitleDisplayMode(.inline)
        }
    }
}
