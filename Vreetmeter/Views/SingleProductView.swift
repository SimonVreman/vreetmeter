
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
        let date = navigation.date
        
        let update = Eetmeter.ProductUpdate(
            id: product.storedAs ?? UUID(),
            period: meal.id,
            consumptionDate: date.startOfDay,
            amount: amount ?? 1,
            productUnitID: unit!.id,
            brandProductID: brandProductId
        )
        
        Task {
            try? await eetmeterAPI.saveProduct(update: update)
            try? await consumptions.fetchDayConsumptions()
            try? await health.synchronizeConsumptions(day: navigation.date, consumptions: consumptions.dayConsumptions)
            
            DispatchQueue.main.async {
                navigation.reset()
                loading = false
            }
        }
    }
    
    var body: some View {
        ZStack {
            VStack(spacing: 0) {
                ScrollView {
                    VStack(spacing: 8) {
                        GroupBox {
                            let isUnprepared = preparationVariant?.product.preparationMethod.isRaw ?? true
                            let nutrition = isUnprepared ? baseNutrition : (preparationVariant?.product ?? baseNutrition)
                            MacroSummary(
                                amount: (amount ?? 0) * Double((unit?.gramsPerUnit ?? 0)),
                                energie: nutrition.energie,
                                eiwit: nutrition.eiwit,
                                koolhydraten: nutrition.koolhydraten,
                                vet: nutrition.vet
                            )
                        }.backgroundStyle(Color(UIColor.secondarySystemGroupedBackground))
                            .padding([.leading, .trailing], 16)
                        
                        ProductAmountForm(
                            products: products,
                            product: product,
                            preparationVariant: $preparationVariant,
                            unit: $unit,
                            amount: $amount
                        ).frame(height: 211).padding(Edge.Set.top, -34)
                    }
                }
                
                Spacer()
                
                Button(action: save, label: { Text("Enter") })
                    .buttonStyle(ActionButtonStyle(disabled: loading || !isValid()))
                    .disabled(loading || !isValid())
                    .padding([.leading, .trailing], 16)
                    .padding(.top, 8)
            }.navigationTitle(productName)
                .navigationBarTitleDisplayMode(.inline)
                .padding([.top, .bottom], 8)
            if (loading) {
                ProgressView()
            }
        }
    }
}
