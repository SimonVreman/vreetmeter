
import Foundation

protocol NutritionalImmutable {
    var energy: Double { get }
    var carbohydrates: Double { get }
    var protein: Double { get }
    var fat: Double { get }
    
    // Optional nutritional values
    // Macronutrients
    var fiber: Double? { get }
    var sugar: Double? { get }
    var fatMonounsaturated: Double? { get }
    var fatPolyunsaturated: Double? { get }
    var fatSaturated: Double? { get }
    var cholesterol: Double? { get }

    // Vitamins
    var vitaminA: Double? { get }
    var thiamin: Double? { get }
    var riboflavin: Double? { get }
    var niacin: Double? { get }
    var pantothenicAcid: Double? { get }
    var vitaminB6: Double? { get }
    var biotin: Double? { get }
    var vitaminB12: Double? { get }
    var vitaminC: Double? { get }
    var vitaminD: Double? { get }
    var vitaminE: Double? { get }
    var vitaminK: Double? { get }
    var folate: Double? { get }
    
    // Minerals
    var calcium: Double? { get }
    var chloride: Double? { get }
    var iron: Double? { get }
    var magnesium: Double? { get }
    var phosphorus: Double? { get }
    var potassium: Double? { get }
    var sodium: Double? { get }
    var zinc: Double? { get }

    // Ultratrace Minerals
    var chromium: Double? { get }
    var copper: Double? { get }
    var iodine: Double? { get }
    var manganese: Double? { get }
    var molybdenum: Double? { get }
    var selenium: Double? { get }
}

protocol Nutritional {
    var energy: Double { get set }
    var carbohydrates: Double { get set }
    var protein: Double { get set }
    var fat: Double { get set }
    
    // Optional nutritional values
    // Macronutrients
    var fiber: Double? { get set }
    var sugar: Double? { get set }
    var fatMonounsaturated: Double? { get set }
    var fatPolyunsaturated: Double? { get set }
    var fatSaturated: Double? { get set }
    var cholesterol: Double? { get set }

    // Vitamins
    var vitaminA: Double? { get set }
    var thiamin: Double? { get set }
    var riboflavin: Double? { get set }
    var niacin: Double? { get set }
    var pantothenicAcid: Double? { get set }
    var vitaminB6: Double? { get set }
    var biotin: Double? { get set }
    var vitaminB12: Double? { get set }
    var vitaminC: Double? { get set }
    var vitaminD: Double? { get set }
    var vitaminE: Double? { get set }
    var vitaminK: Double? { get set }
    var folate: Double? { get set }
    
    // Minerals
    var calcium: Double? { get set }
    var chloride: Double? { get set }
    var iron: Double? { get set }
    var magnesium: Double? { get set }
    var phosphorus: Double? { get set }
    var potassium: Double? { get set }
    var sodium: Double? { get set }
    var zinc: Double? { get set }

    // Ultratrace Minerals
    var chromium: Double? { get set }
    var copper: Double? { get set }
    var iodine: Double? { get set }
    var manganese: Double? { get set }
    var molybdenum: Double? { get set }
    var selenium: Double? { get set }
}

extension Nutritional {
    mutating func fillOptionalNutrionalValues(p: EetmeterNutritional, consumed: Double?) {
        let consumedFactor = consumed != nil ? consumed! / 100 : 1
        
        let convertGrams = { (amount: Double?) -> Double? in amount != nil ? amount! * consumedFactor : nil }
        let convertMilligrams = { (amount: Double?) -> Double? in amount != nil ? amount! * consumedFactor / 1_000 : nil }
        let convertMicrograms = { (amount: Double?) -> Double? in amount != nil ? amount! * consumedFactor / 1_000_000 : nil }
        
        // Macronutrients
        self.fiber = convertGrams(p.vezels)
        self.sugar = convertGrams(p.suikers)
        self.fatSaturated = convertGrams(p.verzadigdVet)

        // Vitamins
        self.vitaminA = convertMicrograms(p.vitamineA)
        self.thiamin = convertMilligrams(p.vitamineB1)
        self.riboflavin = convertMilligrams(p.vitamineB2)
        self.niacin = convertMilligrams(p.nicotinezuur)
        self.vitaminB6 = convertMilligrams(p.vitamineB6)
        self.vitaminB12 = convertMicrograms(p.vitamineB12)
        self.vitaminC = convertMilligrams(p.vitamineC)
        self.vitaminD = convertMicrograms(p.vitamineD)
        self.vitaminE = convertMilligrams(p.vitamineE)
        self.folate = convertMicrograms(p.foliumzuur)
        
        // Minerals
        self.calcium = convertMilligrams(p.calcium)
        self.iron = convertMilligrams(p.iJzer)
        self.magnesium = convertMilligrams(p.magnesium)
        self.phosphorus = convertMilligrams(p.fosfor)
        self.potassium = convertMilligrams(p.kalium)
        self.sodium = convertMilligrams(p.natrium)
        self.zinc = convertMilligrams(p.zink)

        // Ultratrace Minerals
        self.iodine = convertMicrograms(p.jodium)
        self.selenium = convertMicrograms(p.selenium)
    }
}
