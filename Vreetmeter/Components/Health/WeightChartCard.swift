
import SwiftUI
import Charts

struct WeightChartCard: View {
    var domain: [Date]
    var data: [NumericalDatePoint]
    
    func getAverage(days: Int) -> Double? {
        let start = Calendar.current.date(byAdding: .day, value: -7, to: Date.now)!
        let recentPoints = data.filter { $0.date > start }
        if recentPoints.isEmpty { return nil }
        return recentPoints.reduce(0) { $0 + $1.value } / Double(recentPoints.count)
    }
    
    var body: some View {
        GroupBox {
            WeightChart(domain: domain, data: data, zones: 4).frame(height: 300)
        }.cardBackgroundAndShadow()
    }
}
