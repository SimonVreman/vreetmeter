
import SwiftUI

struct TextInputStyle: TextFieldStyle {
    var disabled = false
    func _body(configuration: TextField<Self._Label>) -> some View {
        configuration
            .padding([.top, .bottom], 10)
            .padding([.leading, .trailing], 16)
            .background(disabled ? .gray : Color(.systemGray6))
            .cornerRadius(10)
    }
}
