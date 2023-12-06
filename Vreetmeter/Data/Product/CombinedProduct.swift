
import Foundation

class CombinedProduct: Product {
    var id: UUID
    var name: String
    var portions: Int
    var items: [CombinedProductIngredient]
    
    var energy: Double { self.optionalSummation({ $0.energy }) ?? 0 }
    var carbohydrates: Double { self.optionalSummation({ $0.carbohydrates }) ?? 0 }
    var protein: Double { self.optionalSummation({ $0.protein }) ?? 0 }
    var fat: Double { self.optionalSummation({ $0.fat }) ?? 0 }
    
    // Optional nutritional values
    // Macronutrients
    var fiber: Double? { self.optionalSummation({ $0.fiber }) }
    var sugar: Double? { self.optionalSummation({ $0.sugar }) }
    var fatMonounsaturated: Double? { self.optionalSummation({ $0.fatMonounsaturated }) }
    var fatPolyunsaturated: Double? { self.optionalSummation({ $0.fatPolyunsaturated }) }
    var fatSaturated: Double? { self.optionalSummation({ $0.fatSaturated }) }
    var cholesterol: Double? { self.optionalSummation({ $0.cholesterol }) }

    // Vitamins
    var vitaminA: Double? { self.optionalSummation({ $0.vitaminA }) }
    var thiamin: Double? { self.optionalSummation({ $0.thiamin }) }
    var riboflavin: Double? { self.optionalSummation({ $0.riboflavin }) }
    var niacin: Double? { self.optionalSummation({ $0.niacin }) }
    var pantothenicAcid: Double? { self.optionalSummation({ $0.pantothenicAcid }) }
    var vitaminB6: Double? { self.optionalSummation({ $0.vitaminB6 }) }
    var biotin: Double? { self.optionalSummation({ $0.biotin }) }
    var vitaminB12: Double? { self.optionalSummation({ $0.vitaminB12 }) }
    var vitaminC: Double? { self.optionalSummation({ $0.vitaminC }) }
    var vitaminD: Double? { self.optionalSummation({ $0.vitaminD }) }
    var vitaminE: Double? { self.optionalSummation({ $0.vitaminE }) }
    var vitaminK: Double? { self.optionalSummation({ $0.vitaminK }) }
    var folate: Double? { self.optionalSummation({ $0.folate }) }
    
    // Minerals
    var calcium: Double? { self.optionalSummation({ $0.calcium }) }
    var chloride: Double? { self.optionalSummation({ $0.chloride }) }
    var iron: Double? { self.optionalSummation({ $0.iron }) }
    var magnesium: Double? { self.optionalSummation({ $0.magnesium }) }
    var phosphorus: Double? { self.optionalSummation({ $0.phosphorus }) }
    var potassium: Double? { self.optionalSummation({ $0.potassium }) }
    var sodium: Double? { self.optionalSummation({ $0.sodium }) }
    var zinc: Double? { self.optionalSummation({ $0.zinc }) }

    // Ultratrace Minerals
    var chromium: Double? { self.optionalSummation({ $0.chromium }) }
    var copper: Double? { self.optionalSummation({ $0.copper }) }
    var iodine: Double? { self.optionalSummation({ $0.iodine }) }
    var manganese: Double? { self.optionalSummation({ $0.manganese }) }
    var molybdenum: Double? { self.optionalSummation({ $0.molybdenum }) }
    var selenium: Double? { self.optionalSummation({ $0.selenium }) }
    
    init(product: Eetmeter.CombinedProduct, items: [CombinedProductIngredient]) {
        self.id = product.id
        self.name = product.name
        self.portions = product.numberOfPortions
        self.items = items
    }
    
    private func optionalSummation(_ getter: ((CombinedProductIngredient) -> Double?)) -> Double? {
        let sum = self.items.reduce(nil) { (sum: Double?, product: CombinedProductIngredient) -> Double? in
            if getter(product) == nil { return sum }
            return (sum ?? 0) + getter(product)!
        }
        return sum
    }
}
