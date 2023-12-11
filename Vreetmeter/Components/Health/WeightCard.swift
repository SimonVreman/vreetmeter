
import SwiftUI
import Charts

struct WeightCard: View {
    var data: [NumericalDatePoint]
    
    func getAverage(days: Int) -> Double? {
        let start = Calendar.current.date(byAdding: .day, value: -7, to: Date.now)!
        let recentPoints = data.filter { $0.date > start }
        if recentPoints.isEmpty { return nil }
        return recentPoints.reduce(0) { $0 + $1.value } / Double(recentPoints.count)
    }
    
    var body: some View {
        GroupBox {
            VStack(alignment: .leading) {
                HStack(alignment: .firstTextBaseline) {
                    let average = getAverage(days: 7)
                    
                    Text(average != nil ? "\(average!, specifier: "%.1f")" : "--.-")
                        .font(.largeTitle).fontDesign(.rounded).fontWeight(.semibold)
                    + Text("kg").font(.headline).foregroundStyle(.primary.secondary)
                    
                    Spacer()
                    
                    Text("7 day average").font(.headline).foregroundStyle(.primary.secondary)
                }
                
                if data.count > 1 { WeightChart(data: data).frame(height: 200) }
            }
        }.cardBackgroundAndShadow()
    }
}
