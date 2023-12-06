
import SwiftUI

struct ConsumptionSummaryProperty: View {
    var value: Double
    var unit: String
    
    var body: some View {
        Text(value.formatNutritional())
            .font(.system(.body, design: .rounded, weight: .semibold)).foregroundColor(.primary) +
        Text(unit).font(.system(.body, weight: .semibold)).foregroundColor(.secondary)
    }
}

#Preview {
    HStack {
        ConsumptionSummaryProperty(value: 12000, unit: "unit")
        ConsumptionSummaryProperty(value: 1200, unit: "unit")
        ConsumptionSummaryProperty(value: 2200, unit: "unit")
        ConsumptionSummaryProperty(value: 100, unit: "unit")
        ConsumptionSummaryProperty(value: 5, unit: "unit")
    }
}
