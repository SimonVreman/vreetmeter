
import SwiftUI
import Charts

struct MealEntry: View {
    
    struct EntryLabels {
        let productName: String
        let brandName: String
        let unitName: String
        let amount: Double
    }
    
    var consumption: Consumption
    var detailed: Bool
    
    var labels: EntryLabels {
        if let c = self.consumption as? GenericConsumption {
            return EntryLabels(productName: c.productName, brandName: "Algemeen", unitName: c.unitName, amount: c.amount)
        } else if let c = self.consumption as? BrandConsumption {
            return EntryLabels(productName: c.productName, brandName: c.brandName, unitName: c.unitName, amount: c.amount)
        } else if self.consumption is GuessConsumption {
            return EntryLabels(productName: "Gokje", brandName: "Beter klopt dit", unitName: "Voetbalveld", amount: 1)
        }
        return EntryLabels(productName: "Onbekend", brandName: "Geen idee", unitName: "?", amount: 0)
    }
    
    var body: some View {
        VStack(spacing: 4) {
            HStack {
                VStack(alignment: .leading, spacing: -2) {
                    Text(labels.productName)
                    Text(labels.brandName)
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .lineLimit(1)
                        .truncationMode(.tail)
                }
                Spacer()
                VStack(alignment: .trailing, spacing: -2) {
                    let rounded = (labels.amount * 10).rounded() / 10
                    let specifier = rounded.truncatingRemainder(dividingBy: 1) == 0 ? "%.0f" : "%.1f"
                    Text("\(labels.amount, specifier: specifier)")
                    Text(labels.unitName)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            
            if (detailed) {
                HStack {
                    ConsumptionSummaryProperty(value: consumption.energy, unit: "kcal")
                    Divider()
                    ConsumptionSummaryProperty(value: consumption.carbohydrates, unit: "c")
                    Divider()
                    ConsumptionSummaryProperty(value: consumption.protein, unit: "p")
                    Divider()
                    ConsumptionSummaryProperty(value: consumption.fat, unit: "f")
                    Spacer()
                }.fixedSize(horizontal: false, vertical: true)
            }
            
            MacroLine(
                carbs: consumption.carbohydrates,
                protein: consumption.protein,
                fat: consumption.fat,
                height: detailed ? 10 : 5
            )
        }
    }
}
