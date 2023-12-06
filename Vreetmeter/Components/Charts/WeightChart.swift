
import SwiftUI
import Charts

struct WeightChart: View {
    var data: [NumericalDatePoint]
    
    var body: some View {
        Chart(data, id: \.date) {
            LineMark(
                x: .value("Day", $0.date),
                y: .value("Weight", $0.value)
            ).foregroundStyle(.red)
            PointMark(
                x: .value("Day", $0.date),
                y: .value("Weight", $0.value)
            ).foregroundStyle(.red)
        }.chartYScale(domain: .automatic(includesZero: false))
            .chartXAxis {
                AxisMarks(format: Date.FormatStyle().day(.defaultDigits))
            }
    }
}
