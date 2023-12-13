
import SwiftUI

struct ConsumptionBox: View {
    var label: String
    var icon: String
    var color: Color
    var consumptions: [Consumption]
    var destination: Meal
    
    var body: some View {
        NavigationLink(value: destination) {
            GroupBox(label: HStack {
                Label(label, systemImage: icon).foregroundColor(color)
                
                Spacer()
                
                HStack {
                    SchijfVanVijfIcon(highlighted: consumptions.schijfVanVijfCategories, empty: consumptions.isEmpty)
                        .frame(width: 30)
                        .fixedSize()
                    
                    let percentage = consumptions.percentageSchijfVanVijf
                    Text(percentage != nil ? "\(Int(percentage!.rounded()))" : "--") +
                    Text("%").foregroundStyle(.secondary)
                }
                
                Image(systemName: "chevron.right").foregroundColor(Color(.systemGray4)).imageScale(.small)
            }) {
                ConsumptionSummary(consumptions: consumptions)
                    .fixedSize(horizontal: false, vertical: true)
            }.cardBackgroundAndShadow()
        }.listRowSeparator(.hidden)
            .listRowInsets(.init())
            .listRowBackground(Color.clear)
            .buttonStyle(PlainButtonStyle())
    }
}

#Preview {
    NavigationView {
        let meal = Meal.breakfast
        ConsumptionBox(label: meal.getLabel(), icon: meal.getIcon(), color: meal.getColor(), consumptions: [], destination: meal)
    }
}
