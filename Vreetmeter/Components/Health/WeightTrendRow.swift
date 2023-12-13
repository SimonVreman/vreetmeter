
import SwiftUI

struct WeightTrendRow: View {
    var firstRange: [NumericalDatePoint]
    var secondRange: [NumericalDatePoint]
    
    private var trend: Double? {
        if firstRange.isEmpty || secondRange.isEmpty { return nil }
        return secondRange.average()! - firstRange.average()!
    }
    
    private var trendFraction: Double? {
        if firstRange.isEmpty || secondRange.isEmpty { return nil }
        return ((secondRange.average()! / firstRange.average()!) - 1) * 100
    }
    
    var body: some View {
        GridRow {
            VStack(alignment: .leading) {
                TrendIndicator(value: trendFraction)
            }
            
            Text("/").fontDesign(.rounded).foregroundStyle(.tertiary)
            
            VStack(alignment: .leading) {
                Text(trend == nil ? "--.-" : "\(trend!, specifier: "%.1f")").fontDesign(.rounded) +
                Text("kg").font(.headline).foregroundStyle(.secondary)
            }
            
            Spacer().gridCellUnsizedAxes(.vertical)
        }.font(.title).fontWeight(.semibold)
    }
}
