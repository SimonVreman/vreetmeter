
import SwiftUI

struct DailyConsumptionList: View {
    var consumptions: [Consumption]
    
    var body: some View {
        VStack {
            ForEach(Meal.allCases, id: \.self) { meal in
                ConsumptionBox(
                    label: meal.getLabel(),
                    icon: meal.getIcon(),
                    color: meal.getColor(),
                    consumptions: consumptions.filter { c in c.meal == meal },
                    destination: meal
                )
            }
        }
    }
}
