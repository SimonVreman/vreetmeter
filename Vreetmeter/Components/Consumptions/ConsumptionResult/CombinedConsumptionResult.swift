
import SwiftUI

struct CombinedConsumptionResult: View {
    var label: String
    
    var body: some View {
        ConsumptionResult(
            label: label,
            sublabel: "Eigen gerecht",
            icon: AnyView(Image(systemName: "stove.fill").foregroundColor(.blue))
        )
    }
}
