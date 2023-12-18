
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
        
        let convertGrams = { (amount: Double?, fallback: Double?) -> Double? in amount != nil ? amount! * consumedFactor : fallback }
        let convertMilligrams = { (amount: Double?, fallback: Double?) -> Double? in amount != nil ? amount! * consumedFactor / 1_000 : fallback }
        let convertMicrograms = { (amount: Double?, fallback: Double?) -> Double? in amount != nil ? amount! * consumedFactor / 1_000_000 : fallback }
        
        // Macronutrients
        self.fiber = convertGrams(p.vezels, self.fiber)
        self.sugar = convertGrams(p.suikers, self.sugar)
        self.fatSaturated = convertGrams(p.verzadigdVet, self.fatSaturated)

        // Vitamins
        self.vitaminA = convertMicrograms(p.vitamineA, self.vitaminA)
        self.thiamin = convertMilligrams(p.vitamineB1, self.thiamin)
        self.riboflavin = convertMilligrams(p.vitamineB2, self.riboflavin)
        self.niacin = convertMilligrams(p.nicotinezuur, self.niacin)
        self.vitaminB6 = convertMilligrams(p.vitamineB6, self.vitaminB6)
        self.vitaminB12 = convertMicrograms(p.vitamineB12, self.vitaminB12)
        self.vitaminC = convertMilligrams(p.vitamineC, self.vitaminC)
        self.vitaminD = convertMicrograms(p.vitamineD, self.vitaminD)
        self.vitaminE = convertMilligrams(p.vitamineE, self.vitaminE)
        self.folate = convertMicrograms(p.foliumzuur, self.folate)
        
        // Minerals
        self.calcium = convertMilligrams(p.calcium, self.calcium)
        self.iron = convertMilligrams(p.iJzer, self.iron)
        self.magnesium = convertMilligrams(p.magnesium, self.magnesium)
        self.phosphorus = convertMilligrams(p.fosfor, self.phosphorus)
        self.potassium = convertMilligrams(p.kalium, self.potassium)
        self.sodium = convertMilligrams(p.natrium, self.sodium)
        self.zinc = convertMilligrams(p.zink, self.zinc)

        // Ultratrace Minerals
        self.iodine = convertMicrograms(p.jodium, self.iodine)
        self.selenium = convertMicrograms(p.selenium, self.selenium)
    }
    
    func getLabelForProperty(_ path: KeyPath<Nutritional, Any>) -> String {
        switch path {
        case \.energy: return "Energy"
        case \.carbohydrates: return "Carbohydrates"
        case \.protein: return "Protein"
        case \.fat: return "Fat"
            
        case \.fiber: return "Fiber"
        case \.sugar: return "Sugar"
        case \.fatMonounsaturated: return "Fat monounsaturated"
        case \.fatPolyunsaturated: return "Fat polyunsaturated"
        case \.fatSaturated: return "Fat saturated"
        case \.cholesterol: return "Cholesterol"
            
        case \.vitaminA: return "Vitamin A"
        case \.thiamin: return "Thiamin"
        case \.riboflavin: return "Riboflavin"
        case \.niacin: return "Niacin"
        case \.pantothenicAcid: return "Pantothenic acid"
        case \.vitaminB6: return "Vitamin B6"
        case \.biotin: return "Biotin"
        case \.vitaminB12: return "Vitamin B12"
        case \.vitaminC: return "Vitamin C"
        case \.vitaminD: return "Vitamin D"
        case \.vitaminE: return "Vitamin E"
        case \.vitaminK: return "Vitamin K"
        case \.folate: return "Folate"
            
        case \.calcium: return "Calcium"
        case \.chloride: return "Chloride"
        case \.iron: return "Iron"
        case \.magnesium: return "Magnesium"
        case \.phosphorus: return "Phosphorus"
        case \.potassium: return "Potassium"
        case \.sodium: return "Sodium"
        case \.zinc: return "Zinc"
            
        case \.chromium: return "Chromium"
        case \.copper: return "Copper"
        case \.iodine: return "Iodine"
        case \.manganese: return "Manganese"
        case \.molybdenum: return "Molybdenum"
        case \.selenium: return "Selenium"
        default: return ""
        }
    }
}
