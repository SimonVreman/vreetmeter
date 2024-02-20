
import SwiftUI

struct CombinedProductView: View {
    @Environment(EetmeterAPI.self) var eetmeterAPI
    @Environment(ConsumptionState.self) var consumptions
    @Environment(TrackingNavigationState.self) var navigation
    @Environment(HealthState.self) var health
    
    var product: CombinedProduct
    
    @State var amount: Double?
    @State var loading: Bool = false
    
    func isValid() -> Bool {
        return amount != nil && amount! > 0 && amount! < 5000
    }
    
    func save() {
        loading = true
        let meal = navigation.meal!
        let date = navigation.date
        
        let update = Eetmeter.CombinedProductUpdate(
            amount: amount ?? 1,
            period: meal.id,
            consumptionDate: date
        )
        
        Task {
            try? await eetmeterAPI.saveCombinedProduct(id: product.id, update: update)
            try? await consumptions.fetchForDay(date, tryCache: false)
            try? await health.synchronizeConsumptions(day: date, consumptions: consumptions.getAllForDay(date))
            
            DispatchQueue.main.async {
                navigation.productSaved()
                loading = false
            }
        }
    }
    
    var body: some View {
        ZStack {
            VStack(spacing: 0) {
                let portionCorrection = 100 / Double(product.portions)
                
                MacroSummary(
                    amount: amount,
                    energie: product.energy * portionCorrection,
                    eiwit: product.protein * portionCorrection,
                    koolhydraten: product.carbohydrates * portionCorrection,
                    vet: product.fat * portionCorrection
                ).padding(16)
                    .background(Color(UIColor.secondarySystemGroupedBackground))
                Divider()
                
                List {
                    UnitAmountPicker(amount: $amount, isGrams: true)
                }.listStyle(.plain)
                
                Divider()
                Button(action: save, label: { Text("Enter") })
                    .buttonStyle(ActionButtonStyle(disabled: loading || !isValid()))
                    .disabled(loading || !isValid())
            }.toolbar { ToolbarItem(placement: .topBarTrailing) {
                ToggleFavoriteButton(update: Eetmeter.FavoriteUpdate(amount: amount ?? 1, combinedProductID: product.id))
            } }.navigationTitle(product.name)
                .navigationBarTitleDisplayMode(.inline)
            if (loading) {
                ProgressView()
            }
        }
    }
}
