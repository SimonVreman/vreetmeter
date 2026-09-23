
import SwiftUI

struct ActionButtonStyle: ButtonStyle {
    var disabled = false
    
    func makeBody(configuration: Self.Configuration) -> some View {
        configuration.label
            .padding(16)
            .frame(maxWidth: .infinity)
            .foregroundStyle(disabled ? Color(.systemGray2) : .white)
            .font(.system(.body, weight: .bold))
            .glassEffect(disabled ? .regular : .regular.tint(.blue).interactive(), in: .capsule)
    }
}

#Preview {
    Button(action: {}, label: { Text("Button") })
        .buttonStyle(ActionButtonStyle(disabled: true))
        .padding(16)
}
