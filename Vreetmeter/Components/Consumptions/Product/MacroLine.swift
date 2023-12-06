
import SwiftUI
import Charts

struct MacroLine: View {
    var carbs: Double
    var protein: Double
    var fat: Double
    var height: Float
    
    var body: some View {
        Chart {
            BarMark(x: .value("Carbs", carbs * 4), stacking: .normalized)
                .foregroundStyle(by: .value("source", "Carbs"))
            BarMark(x: .value("Protein", protein * 4), stacking: .normalized)
                .foregroundStyle(by: .value("source", "Protein"))
            BarMark(x: .value("Fat", fat * 9), stacking: .normalized)
                .foregroundStyle(by: .value("source", "Fat"))
        }.frame(height: CGFloat(height))
            .chartXScale(domain: [0, 100])
            .chartLegend(.hidden)
            .chartXAxis(.hidden)
    }
}
