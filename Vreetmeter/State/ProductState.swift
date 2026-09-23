
import SwiftUI

@Observable class ProductState {
    private let api: EetmeterAPI
    var combinedProducts: [CombinedProduct]
    
    init(api: EetmeterAPI) {
        self.api = api
        self.combinedProducts = []
    }
    
    func fetchCombinedProducts() async throws {
        let products = try await self.api.fetchCombinedProducts()
        
        // Transform to proper types
        var filledProducts: [CombinedProduct] = []
        for p in products {
            do {
                filledProducts.append(CombinedProduct(product: p, items: try await self.fetchIngredients(p)))
            } catch {
                // Skip recipes we cannot resolve instead of failing the whole list
                print("Skipping combined product \(p.name): \(error)")
            }
        }
        
        self.combinedProducts = filledProducts
    }
    
    private func fetchIngredients(_ p: Eetmeter.CombinedProduct) async throws -> [CombinedProductIngredient] {
        var ingredients: [CombinedProductIngredient] = []
        for i in p.items {
            let unit = try await self.api.getUnit(id: i.productUnitId, brandProductId: i.brandProductId)
            let amount = i.amount * Double(unit.gramsPerUnit)
            
            var nutritional: EetmeterNutritional
            if let brandProductId = i.brandProductId {
                let product = try await self.api.getBrandProduct(id: brandProductId)
                let variant = product.product.preparationVariants.first { v in v.product.units.contains { u in u.id == i.productUnitId } }
                nutritional = variant == nil || variant!.product.preparationMethod.isRaw ? product : variant!.product
            } else {
                let product = try await self.api.getProduct(id: i.productUnitId, isUnit: true)
                guard let variant = product.preparationVariants.first(where: { v in v.product.units.contains { u in u.id == i.productUnitId } }) else {
                    throw EetmeterError.unitNotFound(i.productUnitId)
                }
                nutritional = variant.product
            }
            
            var ingredient = CombinedProductIngredient(id: i.id, nutritional: nutritional, amount: amount)
            ingredient.fillOptionalNutrionalValues(p: nutritional, consumed: amount)
            ingredients.append(ingredient)
        }
        return ingredients
    }
}
