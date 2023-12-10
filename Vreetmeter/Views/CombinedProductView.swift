
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
            try? await consumptions.fetchDayConsumptions()
            try? await health.synchronizeConsumptions(day: navigation.date, consumptions: consumptions.dayConsumptions)
            
            DispatchQueue.main.async {
                navigation.removeLast()
                loading = false
            }
        }
    }
    
    var body: some View {
        ZStack {
            VStack(spacing: 0) {
                ScrollView {
                    VStack {
                        GroupBox {
                            let portionCorrection = 100 / Double(product.portions)
                            MacroSummary(
                                amount: amount,
                                energie: product.energy * portionCorrection,
                                eiwit: product.protein * portionCorrection,
                                koolhydraten: product.carbohydrates * portionCorrection,
                                vet: product.fat * portionCorrection
                            )
                        }.backgroundStyle(Color(UIColor.secondarySystemGroupedBackground))
                            
                        GroupBox {
                            UnitAmountPicker(amount: $amount, isGrams: true)
                        }.backgroundStyle(Color(UIColor.secondarySystemGroupedBackground))
                    }.padding([.leading, .trailing], 16)
                }
                
                Spacer()
                
                Button(action: save, label: { Text("Enter") })
                    .buttonStyle(ActionButtonStyle(disabled: loading || !isValid()))
                    .disabled(loading || !isValid())
                    .padding([.leading, .trailing], 16)
                    .padding(.top, 8)
            }.toolbar { ToolbarItem(placement: .topBarTrailing) {
                ToggleFavoriteButton(update: Eetmeter.FavoriteUpdate(amount: amount ?? 1, combinedProductID: product.id))
            } }.navigationTitle(product.name)
                .navigationBarTitleDisplayMode(.inline)
                .padding([.top, .bottom], 8)
            if (loading) {
                ProgressView()
            }
        }
    }
}
