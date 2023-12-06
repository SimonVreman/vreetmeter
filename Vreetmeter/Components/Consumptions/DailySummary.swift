
import SwiftUI

struct DailySummary: View {
    var bodyMass: Double
    var energyGoal: Int
    var consumptions: [Consumption]
    
    var body: some View {
        VStack(spacing: 0) {
            let energy: Double = Double(energyGoal)
            let fatMinimum: Double = 2.2 * bodyMass * 0.3
            let fatMaximum: Double = 2.2 * bodyMass * 0.5
            let protein: Double = 2.2 * bodyMass
            let carbsMinimum: Double = (energy - protein * 4 - fatMaximum * 9) / 4
            let carbsMaximum: Double = (energy - protein * 4 - fatMinimum * 9) / 4
            
            let fatGoal = Int(fatMinimum.rounded())
            let fatMaxGoal = Int(fatMaximum.rounded())
            let proteinGoal = Int(protein.rounded())
            let energyGoal = Int(energy.rounded())
            let carbGoal = Int(carbsMinimum.rounded())
            let carbMaxGoal = Int(carbsMaximum.rounded())
            
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
            
            Grid {
                GridRow {
                    let value = Int(consumptions.reduce(0) { $0 + $1.carbohydrates }.rounded())
                    DailySummaryGraph(value: value, color: .blue, goal: carbGoal, limit: carbMaxGoal)
                    HStack {
                        Text("\(value)").font(.system(.headline, design: .rounded)).bold() +
                        Text("/\(carbGoal)c").font(.footnote.bold()).foregroundStyle(.secondary)
                    }.gridColumnAlignment(.leading)
                }
                GridRow {
                    let value = Int(consumptions.reduce(0) { $0 + $1.protein }.rounded())
                    DailySummaryGraph(value: value, color: .green, goal: proteinGoal)
                    HStack {
                        Text("\(value)").font(.system(.headline, design: .rounded)).bold() +
                        Text("/\(proteinGoal)p").font(.footnote.bold()).foregroundStyle(.secondary)
                    }.gridColumnAlignment(.leading)
                }
                GridRow {
                    let value = Int(consumptions.reduce(0) { $0 + $1.fat }.rounded())
                    DailySummaryGraph(value: value, color: .orange, goal: fatGoal, limit: fatMaxGoal)
                    HStack {
                        Text("\(value)").font(.system(.headline, design: .rounded)).bold() +
                        Text("/\(fatGoal)f").font(.footnote.bold()).foregroundStyle(.secondary)
                    }.gridColumnAlignment(.leading)
                }
            }
        }
    }
}

#Preview {
    DailySummary(bodyMass: 75, energyGoal: 2000, consumptions: [
        GuessConsumption(id: UUID(), energy: 300, carbohydrates: 140, protein: 250, fat: 60)
    ])
}
