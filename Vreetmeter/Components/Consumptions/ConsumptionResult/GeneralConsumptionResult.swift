
import SwiftUI

struct GeneralConsumptionResult: View {
    var label: String
    var sublabel: String
    
    var body: some View {
        ConsumptionResult(
            label: label,
            sublabel: sublabel
        )
    }
}
