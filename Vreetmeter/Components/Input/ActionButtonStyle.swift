
import SwiftUI

struct ActionButtonStyle: ButtonStyle {
    var disabled = false
    
    func makeBody(configuration: Self.Configuration) -> some View {
        configuration.label
            .padding(16)
            .frame(maxWidth: .infinity)
            .background(disabled ? Color(.systemGray6) : .blue)
            .foregroundColor(disabled ? Color(.systemGray2) : .white)
            .clipShape(.rect(cornerRadius: 15))
            .font(.system(.body, weight: .bold))
    }
}

#Preview {
    Button(action: {}, label: { Text("Button") })
        .buttonStyle(ActionButtonStyle(disabled: true))
        .padding(16)
}
