
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
            var ingredients: [CombinedProductIngredient] = []
            for i in p.items {
                let isBrand = i.brandProductId != nil
                let unit = try await self.api.getUnit(id: i.productUnitId)
                let amount = i.amount * Double(unit.gramsPerUnit)
                
                var nutritional: EetmeterNutritional
                if (isBrand) {
                    let product = try await self.api.getBrandProduct(id: i.brandProductId!)
                    let variant = product.product.preparationVariants.first { v in v.product.units.contains { u in u.id == i.productUnitId } }
                    nutritional = variant == nil || variant!.product.preparationMethod.isRaw ? product : variant!.product
                } else {
                    let product = try await self.api.getProduct(id: i.productUnitId, isUnit: true)
                    nutritional = product.preparationVariants.first { v in v.product.units.contains { u in u.id == i.productUnitId } }!.product
                }
        
                var ingredient = CombinedProductIngredient(id: i.id, nutritional: nutritional, amount: amount)
                ingredient.fillOptionalNutrionalValues(p: nutritional, consumed: amount)
                ingredients.append(ingredient)
            }
            
            filledProducts.append(CombinedProduct(product: p, items: ingredients))
        }
        
        let combinedProducts = filledProducts
        DispatchQueue.main.async { self.combinedProducts = combinedProducts }
    }
}
