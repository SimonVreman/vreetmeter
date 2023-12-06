
import SwiftUI

struct ConsumptionSummary: View {
    let consumptions: [Consumption]
    
    var body: some View {
        VStack(alignment: .leading, content: {
            let energy = consumptions.reduce(0) { $0 + $1.energy }
            let carbs = consumptions.reduce(0) { $0 + $1.carbohydrates }
            let protein = consumptions.reduce(0) { $0 + $1.protein }
            let fat = consumptions.reduce(0) { $0 + $1.fat }
            
            HStack {
                ConsumptionSummaryProperty(value: energy, unit: "kcal")
                Divider()
                ConsumptionSummaryProperty(value: carbs, unit: "c")
                Divider()
                ConsumptionSummaryProperty(value: protein, unit: "p")
                Divider()
                ConsumptionSummaryProperty(value: fat, unit: "f")
                Spacer()
            }
            
            MacroLine(carbs: carbs, protein: protein, fat: fat, height: 5)
        })
    }
}
