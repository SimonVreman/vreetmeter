
import SwiftUI

struct DailyEnergySummary: View {
    var bodyMass: Double
    var energyGoal: Int
    var consumptions: [Consumption]

    var body: some View {
        HStack {
            let calories = consumptions.reduce(0) { $0 + $1.energy }
            let percentage = calories / Double(energyGoal) * 100
            
            Text("\(Int(calories.rounded()))")
                .font(.system(.title, design: .rounded, weight: .semibold)) +
            Text("/\(energyGoal)kcal").font(.system(.body, weight: .semibold)).foregroundStyle(.secondary)
            Spacer()
            Text("\(Int(percentage.rounded()))")
                .font(.system(.title, design: .rounded, weight: .semibold)) +
            Text("%").font(.system(.title, design: .rounded, weight: .semibold)).foregroundStyle(.secondary)
        }
    }
}
