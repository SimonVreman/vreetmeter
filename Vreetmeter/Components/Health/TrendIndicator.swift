
import SwiftUI

struct TrendIndicator: View {
    var value: Double?
    
    private var numberString: String {
        if value == nil {
            return "-.-"
        } else if abs(value!) < 1 {
            return String(String(format: "%.2f", abs(value!)).dropFirst())
        } else {
            return String(format: "%.1f", abs(value!))
        }
    }
    
    private var icon: String {
        if value == nil || abs(value!) < 0.005 {
            return "chevron.up.chevron.down"
        } else if value! > 0 {
            return "arrow.up"
        } else {
            return "arrow.down"
        }
    }
    
    private var color: Color {
        if value == nil || abs(value!) < 0.005 {
            return .primary
        } else if value! > 0 {
            return .green
        } else {
            return .red
        }
    }
    
    var body: some View {
        HStack {
            Image(systemName: icon).font(.callout).foregroundStyle(color)
            Text(numberString) + Text("%").foregroundStyle(.secondary)
        }.font(.title).fontDesign(.rounded).fontWeight(.semibold)
    }
}

#Preview {
    VStack {
        TrendIndicator(value: nil)
        TrendIndicator(value: 0.0049)
        TrendIndicator(value: 5)
        TrendIndicator(value: -5)
        TrendIndicator(value: 0.25)
        TrendIndicator(value: -0.25)
    }
}
