
import SwiftUI
import Combine

struct ProductAmountForm: View {
    @EnvironmentObject var navigation: NavigationState
    var products: [Eetmeter.Product]
    @Binding var preparationVariant: Eetmeter.PreparationVariant?
    @Binding var unit: Eetmeter.ProductUnit?
    @Binding var amount: Double?
    @State var variants: [Eetmeter.PreparationVariant] = []
    @State var units: [Eetmeter.ProductUnit] = []
    
    var body: some View {
        Form {
            Section {
                PreparationVariantPicker(
                    variant: $preparationVariant,
                    variants: variants
                )
                ProductUnitPicker(
                    unit: $unit,
                    units: units
                )
                UnitAmountPicker(amount: $amount, isGrams: (unit?.gramsPerUnit ?? 0) == 1)
            }
        }.scrollContentBackground(.hidden)
            .scrollDisabled(true)
            .onAppear {
                if (preparationVariant != nil) { return }
                
                var uniqueVariants = Set<UUID>()
                variants = products.flatMap { p in p.preparationVariants }.compactMap({ v in
                    if (uniqueVariants.contains(v.id)) { return nil }
                    uniqueVariants.insert(v.id)
                    return v
                }).sorted { $0.sortOrder > $1.sortOrder }
                
                let product: Eetmeter.GenericProduct = navigation.lastOfType()!
                if (product.unitId != nil) {
                    preparationVariant = variants.first { v in v.product.units.contains { u in u.id == product.unitId } }
                        ?? variants.first
                } else {
                    preparationVariant = variants.first
                }
            }.onChange(of: preparationVariant) {
                units = preparationVariant?.product.units.sorted { $0.gramsPerUnit < $1.gramsPerUnit } ?? []
                if (units.isEmpty) { return }
                let product: Eetmeter.GenericProduct = navigation.lastOfType()!
                unit = units.first { u in u.id == product.unitId }
                if (unit != nil) { amount = product.amount ?? amount } else { unit = units.first }
            }
    }
}
