
import Foundation

class CombinedProductIngredient: Nutritional {
    var id: UUID
    
    var energy: Double
    var carbohydrates: Double
    var protein: Double
    var fat: Double
    
    // Optional nutritional values
    // Macronutrients
    var fiber: Double?
    var sugar: Double?
    var fatMonounsaturated: Double?
    var fatPolyunsaturated: Double?
    var fatSaturated: Double?
    var cholesterol: Double?

    // Vitamins
    var vitaminA: Double?
    var thiamin: Double?
    var riboflavin: Double?
    var niacin: Double?
    var pantothenicAcid: Double?
    var vitaminB6: Double?
    var biotin: Double?
    var vitaminB12: Double?
    var vitaminC: Double?
    var vitaminD: Double?
    var vitaminE: Double?
    var vitaminK: Double?
    var folate: Double?
    
    // Minerals
    var calcium: Double?
    var chloride: Double?
    var iron: Double?
    var magnesium: Double?
    var phosphorus: Double?
    var potassium: Double?
    var sodium: Double?
    var zinc: Double?

    // Ultratrace Minerals
    var chromium: Double?
    var copper: Double?
    var iodine: Double?
    var manganese: Double?
    var molybdenum: Double?
    var selenium: Double?
    
    init(id: UUID, nutritional: EetmeterNutritional, amount: Double) {
        self.id = id
        
        let amountFactor = amount / 100
        self.energy = (nutritional.energie ?? 0) * amountFactor
        self.carbohydrates = (nutritional.koolhydraten ?? 0) * amountFactor
        self.protein = (nutritional.eiwit ?? 0) * amountFactor
        self.fat = (nutritional.vet ?? 0) * amountFactor
    }
}
