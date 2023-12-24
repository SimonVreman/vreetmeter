
import SwiftUI

private struct ProgressItem: View {
    var property: PartialKeyPath<Nutritional>
    var progress: Double
    
    var body: some View {
        NutritionalTargetProgress(
            label: NutritionalProperties.getLabelForProperty(property)!,
            target: NutritionalProperties.getTargetForProperty(property)!,
            unit: NutritionalProperties.getUnitForProperty(property)!,
            progress: progress
        )
    }
}

struct NutrientProgressOverview: View {
    @Environment(ConsumptionState.self) var consumptionState
    @State private var startDate: Date = Date.now.startOfDay
    @State private var endDate: Date = Date.now.startOfDay
    @State private var consumptions: [Consumption]?
    
    private let days: Int = 7
    
    private var energyTotal: Double {
        (self.consumptions ?? []).reduce(0) {
            if $1 is GuessConsumption { return $0 }
            return $0 + $1.energy
        }
    }
    
    private func fetchConsumptions() async throws {
        try await self.consumptionState.fetchForRange(start: startDate, days: self.days)
        await MainActor.run {
            self.consumptions = self.consumptionState.getAllForRange(start: startDate, days: self.days)
        }
    }
    
    private func calculateProgress(_ property: PartialKeyPath<Nutritional>) -> Double {
        var progress = (consumptions ?? []).reduce(0) {
            let value = $1[keyPath: property] as? Double
            if value == nil { return $0 }
            return $0 + value!
        }
        
        let unit = NutritionalProperties.getUnitForProperty(property)
        if unit != .gram { progress *= (unit == .milligram ? 1_000 : 1_000_000) }
        
        let target = NutritionalProperties.getTargetForProperty(property)
        if !(target?.per1000kcal ?? false) { return progress / Double(self.days) }
        return progress / (self.energyTotal / 1000)
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            if consumptions != nil {
                let start = startDate.formatted(.dateTime.day(.defaultDigits).month(.abbreviated))
                let end = endDate.formatted(.dateTime.day(.defaultDigits).month(.abbreviated))
                Text("\(start) to \(end)")
                    .font(.title2)
                    .fontWeight(.bold)
                
                GroupBox { VStack {
                    ProgressItem(property: \.fiber, progress: self.calculateProgress(\.fiber))
                    Divider()
                    ProgressItem(property: \.fatSaturated, progress: self.calculateProgress(\.fatSaturated))
                } }.cardBackgroundAndShadow()
                    .padding(.top, 4)
                
                Text("Vitamins").font(.title2).bold().padding(.top)
                GroupBox { VStack {
                    ProgressItem(property: \.vitaminA, progress: self.calculateProgress(\.vitaminA))
                    Divider()
                    ProgressItem(property: \.thiamin, progress: self.calculateProgress(\.thiamin))
                    Divider()
                    ProgressItem(property: \.riboflavin, progress: self.calculateProgress(\.riboflavin))
                    Divider()
                    ProgressItem(property: \.niacin, progress: self.calculateProgress(\.niacin))
                    Divider()
                    ProgressItem(property: \.vitaminB6, progress: self.calculateProgress(\.vitaminB6))
                    Divider()
                    ProgressItem(property: \.vitaminB12, progress: self.calculateProgress(\.vitaminB12))
                    Divider()
                    ProgressItem(property: \.vitaminC, progress: self.calculateProgress(\.vitaminC))
                    Divider()
                    ProgressItem(property: \.vitaminD, progress: self.calculateProgress(\.vitaminD))
                    Divider()
                    ProgressItem(property: \.vitaminE, progress: self.calculateProgress(\.vitaminE))
                    Divider()
                    ProgressItem(property: \.folate, progress: self.calculateProgress(\.folate))
                } }.cardBackgroundAndShadow()
                
                Text("Minerals").font(.title2).bold().padding(.top)
                GroupBox { VStack {
                    ProgressItem(property: \.calcium, progress: self.calculateProgress(\.calcium))
                    Divider()
                    ProgressItem(property: \.iron, progress: self.calculateProgress(\.iron))
                    Divider()
                    ProgressItem(property: \.magnesium, progress: self.calculateProgress(\.magnesium))
                    Divider()
                    ProgressItem(property: \.phosphorus, progress: self.calculateProgress(\.phosphorus))
                    Divider()
                    ProgressItem(property: \.potassium, progress: self.calculateProgress(\.potassium))
                    Divider()
                    ProgressItem(property: \.sodium, progress: self.calculateProgress(\.sodium))
                    Divider()
                    ProgressItem(property: \.zinc, progress: self.calculateProgress(\.zinc))
                } }.cardBackgroundAndShadow()
                
                Text("Ultratrace Minerals").font(.title2).bold().padding(.top)
                GroupBox { VStack {
                    ProgressItem(property: \.iodine, progress: self.calculateProgress(\.iodine))
                    Divider()
                    ProgressItem(property: \.selenium, progress: self.calculateProgress(\.selenium))
                } }.cardBackgroundAndShadow()
            } else {
                ProgressView().centered()
            }
        }.onAppear {
            endDate = Calendar.current.date(byAdding: .second, value: -1, to: Date.now.startOfDay)!
            startDate = Calendar.current.date(byAdding: .day, value: -self.days, to: endDate)!
            Task { try await self.fetchConsumptions() }
        }
            .padding([.horizontal, .bottom])
    }
}

#Preview {
    ScrollView {
        NutrientProgressOverview()
            .environment(ConsumptionState(api: EetmeterAPI()))
    }
}

