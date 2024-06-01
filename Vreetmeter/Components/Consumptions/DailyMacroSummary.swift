
import SwiftUI

struct DailyMacroSummary: View {
    var bodyMass: Double
    var energyGoal: Int
    var consumptions: [Consumption]
    
    var body: some View {
        VStack(spacing: 0) {
            let energy: Double = Double(energyGoal)
            
            // Protein 1.8g/kg
            let protein: Double = 1.8 * bodyMass
            
            // Fat between 0.3g/lb and 0.5g/lb
            let fatMinimum: Double = bodyMass * 0.3 * 2.2
            let fatMaximum: Double = bodyMass * 0.5 * 2.2
            let carbsMinimum: Double = (energy - protein * 4 - fatMaximum * 9) / 4
            let carbsMaximum: Double = (energy - protein * 4 - fatMinimum * 9) / 4
            
            let fatGoal = Int(fatMinimum.rounded())
            let fatMaxGoal = Int(fatMaximum.rounded())
            let proteinGoal = Int(protein.rounded())
            let carbGoal = Int(carbsMinimum.rounded())
            let carbMaxGoal = Int(carbsMaximum.rounded())
            
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
    DailyMacroSummary(bodyMass: 75, energyGoal: 2000, consumptions: [
        GuessConsumption(id: UUID(), energy: 300, carbohydrates: 140, protein: 250, fat: 60)
    ])
}
