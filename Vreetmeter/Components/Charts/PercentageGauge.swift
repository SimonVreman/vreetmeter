
import SwiftUI

struct PercentageGauge: View {
    var percentage: Double?
    
    var body: some View {
        Gauge(value: min((percentage ?? 0), 100) / 100) {
            Text(percentage != nil ? "\(Int(percentage!.rounded()))" : "--")
                .font(.system(.title2, design: .rounded, weight: .semibold)) +
            Text("%").font(.system(.title2, design: .rounded, weight: .semibold)).foregroundStyle(.secondary)
        }.gaugeStyle(.accessoryCircularCapacity)
    }
}

#Preview {
    VStack {
        PercentageGauge()
        PercentageGauge(percentage: 16)
        PercentageGauge(percentage: 87)
        PercentageGauge(percentage: 100)
        PercentageGauge(percentage: 161)
    }
}
