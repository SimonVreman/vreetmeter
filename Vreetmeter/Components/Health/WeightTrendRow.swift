
import SwiftUI

struct WeightTrendRow: View {
    var label: String
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
            Text(label)
                .font(.headline)
                .fontWeight(.regular)
                .foregroundStyle(.secondary)
                .fixedSize(horizontal: true, vertical: false)
            
            VStack(alignment: .leading) {
                TrendIndicator(value: trendFraction)
            }.fixedSize(horizontal: true, vertical: false)
            
            VStack(alignment: .leading) {
                Text(trend == nil ? "--.-" : "\(trend!, specifier: "%.1f")").fontDesign(.rounded) +
                Text("kg").font(.headline).foregroundStyle(.secondary)
            }.fixedSize(horizontal: true, vertical: false)
                .gridColumnAlignment(.trailing)
            
            Spacer().gridCellUnsizedAxes(.vertical)
        }.font(.title).fontWeight(.semibold)
    }
}
