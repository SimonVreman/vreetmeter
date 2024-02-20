
import SwiftUI
import Charts

struct WeightChartCard: View {
    var domain: [Date]
    var data: [NumericalDatePoint]
    
    var body: some View {
        GroupBox {
            WeightChart(domain: domain, data: data, zones: 52).frame(height: 500)
        }.cardBackgroundAndShadow()
    }
}
