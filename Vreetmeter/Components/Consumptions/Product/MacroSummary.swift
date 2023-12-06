
import SwiftUI
import Charts

struct MacroSummary: View {
    var amount: Double?
    var energie: Double?
    var eiwit: Double?
    var koolhydraten: Double?
    var vet: Double?
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                ConsumptionSummaryProperty(
                    value: (energie ?? 0) * Double((amount ?? 0)) / 100,
                    unit: "kcal"
                )
                Divider()
                ConsumptionSummaryProperty(
                    value: (koolhydraten ?? 0) * Double((amount ?? 0)) / 100,
                    unit: "c"
                )
                Divider()
                ConsumptionSummaryProperty(
                    value: (eiwit ?? 0) * Double((amount ?? 0)) / 100,
                    unit: "p"
                )
                Divider()
                ConsumptionSummaryProperty(
                    value: (vet ?? 0) * Double((amount ?? 0)) / 100,
                    unit: "f"
                )
                Spacer()
            }.fixedSize(horizontal: false, vertical: true)
            Chart {
                BarMark(x: .value("Carbs", (koolhydraten ?? 0) * 4), stacking: .normalized)
                    .foregroundStyle(by: .value("source", "Carbs"))
                BarMark(x: .value("Protein", (eiwit ?? 0) * 4), stacking: .normalized)
                    .foregroundStyle(by: .value("source", "Protein"))
                BarMark(x: .value("Fat", (vet ?? 0) * 9), stacking: .normalized)
                    .foregroundStyle(by: .value("source", "Fat"))
            }.frame(height: 75)
                .chartXScale(domain: [0, 100])
        }.frame(maxWidth: .infinity)
    }
}

#Preview {
    VStack {
        MacroSummary()
        MacroSummary(
            amount: 50,
            energie: 90,
            eiwit: 7,
            koolhydraten: 12,
            vet: 5
        )
    }
}
