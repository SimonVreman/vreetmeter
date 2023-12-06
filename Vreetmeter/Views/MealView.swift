
import SwiftUI

struct MealView: View {
    @Environment(EetmeterAPI.self) var eetmeterAPI
    @Environment(ConsumptionState.self) var consumptionState
    @Environment(TrackingNavigationState.self) var navigation
    @Environment(HealthState.self) var health
    @State private var loading: Bool = false
    @State private var detailed: Bool = false
    var meal: Meal
    
    var consumptions: [Consumption] {
        return consumptionState.dayConsumptions.filter { c in c.meal == self.meal }
    }
    
    func getResultForConsumption(consumption: Consumption) -> Eetmeter.GenericProduct? {
        if let c = consumption as? BrandConsumption {
            return Eetmeter.GenericProduct(
                id: c.brandProductId,
                type: .brand,
                storedAs: c.id,
                unitId: c.productUnitId,
                amount: c.amount
            )
        } else if let c = consumption as? GenericConsumption {
            return Eetmeter.GenericProduct(
                id: c.productUnitId,
                type: .unit,
                storedAs: c.id,
                unitId: c.productUnitId,
                amount: c.amount
            )
        }
        return nil
    }
    
    func delete(indexes: IndexSet) {
        // only support on delete
        if (indexes.isEmpty) { return }
        let index = indexes.first!
        if (consumptions.count <= index) { return }
        let consumption = consumptions[index]
        
        loading = true
        Task {
            do {
                if consumption is GuessConsumption {
                    let date = consumption.date ?? navigation.date
                    try await eetmeterAPI.deleteGuess(id: consumption.id, date: date)
                } else {
                    try await eetmeterAPI.deleteProduct(id: consumption.id)
                }
                try await consumptionState.fetchDayConsumptions()
                try await health.synchronizeConsumptions(day: navigation.date, consumptions: consumptionState.dayConsumptions)
                loading = false
            } catch {
                loading = false
            }
        }
    }
    
    var body: some View {
        ZStack {
            VStack(spacing: 0) {
                MacroSummary(
                    amount: 100,
                    energie: consumptions.reduce(0) { $0 + $1.energy },
                    eiwit: consumptions.reduce(0) { $0 + $1.protein },
                    koolhydraten: consumptions.reduce(0) { $0 + $1.carbohydrates },
                    vet: consumptions.reduce(0) { $0 + $1.fat }
                ).padding([.horizontal, .bottom], 16)
                    .background(Color(UIColor.secondarySystemGroupedBackground))
                
                Divider()
                
                List {
                    ForEach(consumptions, id: \.self.id) { c in
                        let link = getResultForConsumption(consumption: c)
                        if (link != nil) {
                            NavigationLink(value: link) {
                                MealEntry(consumption: c, detailed: detailed)
                            }
                        } else {
                            MealEntry(consumption: c, detailed: detailed)
                        }
                    }.onDelete(perform: delete)
                }.listStyle(.plain)
            }.background(Color(UIColor.systemGroupedBackground))
            
            if (loading) {
                ProgressView()
            } else if (consumptions.isEmpty) {
                Text("Don't forget to eat!").foregroundStyle(.secondary)
            }
        }.navigationTitle(meal.getLabel())
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                HStack(spacing: 12) {
                    Spacer()
                    Toggle(isOn: $detailed.animation()) {
                        Image(systemName: detailed ? "minus.magnifyingglass" : "text.magnifyingglass")
                    }
                    NavigationLink(value: ConsumptionSearch(meal: meal)) {
                        Image(systemName: "plus")
                    }
                }
            }
    }
}
