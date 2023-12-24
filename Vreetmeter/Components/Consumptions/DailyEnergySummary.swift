
import SwiftUI

struct DailyEnergySummary: View {
    var energyGoal: Int
    var consumptions: [Consumption]

    var body: some View {
        HStack {
            let calories = consumptions.reduce(0) { $0 + $1.energy }
            let percentage = calories / Double(energyGoal) * 100
            
            VStack(alignment: .leading, spacing: -2) {
                Text("\(Int(calories.rounded()))")
                    .font(.system(.body, design: .rounded, weight: .semibold))
                Text("/\(energyGoal)").font(.system(.body, weight: .semibold)).foregroundStyle(.secondary)
            }
            Spacer()
            PercentageGauge(percentage: percentage)
        }
    }
}


#Preview {
    VStack {
        let guess = GuessConsumption(id: UUID(), energy: 500, carbohydrates: 10, protein: 40, fat: 30)
        DailyEnergySummary(energyGoal: 2500, consumptions: [])
        DailyEnergySummary(energyGoal: 2500, consumptions: [guess])
        DailyEnergySummary(energyGoal: 2500, consumptions: [guess, guess])
    }
}
