
import SwiftUI

struct SingleProductView: View {
    @Environment(EetmeterAPI.self) var eetmeterAPI
    @Environment(ConsumptionState.self) var consumptions
    @Environment(TrackingNavigationState.self) var navigation
    @Environment(HealthState.self) var health
    
    var product: Eetmeter.GenericProduct
    var baseNutrition: EetmeterNutritional
    var products: [Eetmeter.Product]
    var productName: String
    var brandProductId: UUID?

    @State var preparationVariant: Eetmeter.PreparationVariant?
    @State var unit: Eetmeter.ProductUnit?
    @State var amount: Double?
    @State var loading: Bool = false
    
    func isValid() -> Bool {
        return preparationVariant != nil && unit != nil && amount != nil && amount! > 0 && amount! < 1000
    }
    
    func save() {
        loading = true
        let meal = navigation.meal!
        let date = navigation.date.startOfDay
        
        let update = Eetmeter.ProductUpdate(
            id: product.storedAs ?? UUID(),
            period: meal.id,
            consumptionDate: date,
            amount: amount ?? 1,
            productUnitID: unit!.id,
            brandProductID: brandProductId
        )
        
        Task {
            try? await eetmeterAPI.saveProduct(update: update)
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
                let isUnprepared = preparationVariant?.product.preparationMethod.isRaw ?? true
                let nutrition = isUnprepared ? baseNutrition : (preparationVariant?.product ?? baseNutrition)
                
                MacroSummary(
                    amount: (amount ?? 0) * Double((unit?.gramsPerUnit ?? 0)),
                    energie: nutrition.energie,
                    eiwit: nutrition.eiwit,
                    koolhydraten: nutrition.koolhydraten,
                    vet: nutrition.vet
                ).padding(16)
                    .background(Color(UIColor.secondarySystemGroupedBackground))
                Divider()
                
                ProductAmountForm(
                    products: products,
                    product: product,
                    preparationVariant: $preparationVariant,
                    unit: $unit,
                    amount: $amount
                )
                
                Divider()
                Button(action: save, label: { Text("Enter") })
                    .buttonStyle(ActionButtonStyle(disabled: loading || !isValid()))
                    .disabled(loading || !isValid())
            }.toolbar { ToolbarItem(placement: .topBarTrailing) {
                ToggleFavoriteButton(update: Eetmeter.FavoriteUpdate(amount: amount ?? 1, productUnitID: unit?.id, brandProductID: brandProductId))
            } }.navigationTitle(productName)
                .navigationBarTitleDisplayMode(.inline)
            if (loading) {
                ProgressView()
            }
        }
    }
}
