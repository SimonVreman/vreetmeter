
import SwiftUI
import Combine

struct ProductAmountForm: View {
    var products: [Eetmeter.Product]
    var product: Eetmeter.GenericProduct
    @Binding var preparationVariant: Eetmeter.PreparationVariant?
    @Binding var unit: Eetmeter.ProductUnit?
    @Binding var amount: Double?
    @State var variants: [Eetmeter.PreparationVariant] = []
    @State var units: [Eetmeter.ProductUnit] = []
    
    var body: some View {
        List {
            PreparationVariantPicker(
                variant: $preparationVariant,
                variants: variants
            ).padding([.vertical], -8)
            
            ProductUnitPicker(
                unit: $unit,
                units: units
            ).padding([.vertical], -8)
            
            UnitAmountPicker(amount: $amount, isGrams: (unit?.gramsPerUnit ?? 0) == 1)
        }.onAppear {
            if (preparationVariant != nil) { return }
            
            var uniqueVariants = Set<UUID>()
            variants = products.flatMap { p in p.preparationVariants }.compactMap({ v in
                if (uniqueVariants.contains(v.id)) { return nil }
                uniqueVariants.insert(v.id)
                return v
            }).sorted { $0.sortOrder > $1.sortOrder }
            
            if (product.unitId != nil) {
                preparationVariant = variants.first { v in v.product.units.contains { u in u.id == product.unitId } }
                    ?? variants.first
            } else {
                preparationVariant = variants.first
            }
        }.onChange(of: preparationVariant) {
            units = preparationVariant?.product.units.sorted { $0.gramsPerUnit < $1.gramsPerUnit } ?? []
            if (units.isEmpty) { return }
            unit = units.first { u in u.id == product.unitId }
            if (unit != nil) { amount = product.amount ?? amount } else { unit = units.first }
        }.listStyle(.plain)
    }
}
