
import SwiftUI

struct SchijfVanVijfPercentage: View {
    var percentage: Double?

    private var color: Color {
        if percentage == nil {
            return .secondary
        } else if percentage! < 50 {
            return .red
        } else if percentage!  < 85 {
            return .yellow
        }
        return .green
    }
    
    var body: some View {
        Text(percentage != nil ? "\(Int(percentage!.rounded()))" : "--")
            .font(.system(.title, design: .rounded, weight: .semibold))
            .foregroundStyle(color) +
        Text("%").font(.system(.title, design: .rounded, weight: .semibold)).foregroundStyle(color.secondary)
    }
}
