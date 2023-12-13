
import SwiftUI

struct DailySchijfVanVijfSummary: View {
    var consumptions: [Consumption]
    
    private var percentage: Double? {
        consumptions.percentageSchijfVanVijf
    }

    private var color: Color {
        if percentage == nil || percentage! >= 85 {
            return .green
        } else if percentage! >= 40 {
            return .orange
        }
        return .red
    }
    
    var body: some View {
        GroupBox {
            HStack(spacing: 0) {
                Text("SVV")
                    .font(.system(.title, design: .rounded, weight: .semibold))
                    .foregroundStyle(.white)
                Spacer()
                Label(percentage != nil ? "\(Int(percentage!.rounded()))" : "--", systemImage: "leaf.fill")
                    .font(.system(.title, design: .rounded, weight: .semibold))
                    .foregroundStyle(.white)
                Text("%").font(.system(.title, design: .rounded, weight: .semibold)).foregroundStyle(.white.secondary)
            }
        }.backgroundStyle(color)
    }
}

#Preview {
    DailySchijfVanVijfSummary(consumptions: [GuessConsumption(id: UUID(), energy: 500, carbohydrates: 10, protein: 40, fat: 30)])
}
