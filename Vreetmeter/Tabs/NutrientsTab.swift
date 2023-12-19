
import SwiftUI

struct NutrientsTab: View {
    @Environment(ConsumptionState.self) var consumptionState
    
    private var start: Date {
        Calendar.current.date(byAdding: .day, value: self.days - 1, to: Date.now)!
    }
    
    private var consumptions: [Consumption] {
        return self.consumptionState.getAllForRange(start: self.start, days: self.days)
    }
    
    private let days: Int = 7
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack {
                    ForEach(NutritionalProperties.propertiesWithTarget, id: \.self) { property in
                        let progress: Double = consumptions.reduce(0) {
                            let value = $1[keyPath: property] as? Double
                            if value == nil { return $0 }
                            return $0 + value!
                        }
                        NutritionalTargetProgress(
                            label: NutritionalProperties.getLabelForProperty(property)!,
                            target: NutritionalProperties.getTargetForProperty(property)!,
                            unit: NutritionalProperties.getUnitForProperty(property)!,
                            progress: progress
                        )
                    }
                }
            }.navigationTitle("Nutrients")
                .onAppear { Task {
                    try await self.consumptionState.fetchForRange(start: self.start, days: self.days)
                } }
        }
    }
}

#Preview {
    NutrientsTab()
        .environment(ConsumptionState(api: EetmeterAPI()))
}
