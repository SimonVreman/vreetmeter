
import SwiftUI

struct ActionButtonStyle: ButtonStyle {
    var disabled = false
    
    func makeBody(configuration: Self.Configuration) -> some View {
        configuration.label
            .padding(16)
            .frame(maxWidth: .infinity)
            .foregroundStyle(disabled ? Color(.systemGray2) : .white)
            .font(.system(.body, weight: .bold))
            // Not .interactive(): interactive glass handles touches itself and swallows the button's taps
            .glassEffect(.regular.tint(disabled ? nil : .blue), in: .capsule)
            .contentShape(.capsule)
            .opacity(configuration.isPressed ? 0.7 : 1)
            .scaleEffect(configuration.isPressed ? 0.98 : 1)
            .animation(.easeOut(duration: 0.1), value: configuration.isPressed)
    }
}

#Preview {
    Button(action: {}, label: { Text("Button") })
        .buttonStyle(ActionButtonStyle(disabled: true))
        .padding(16)
}
