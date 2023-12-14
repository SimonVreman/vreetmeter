
import Foundation

class GuessConsumption: Consumption {
    var id: UUID
    var date: Date?
    var meal: Meal?
    var grams: Double?
    var energy: Double
    var carbohydrates: Double
    var protein: Double
    var fat: Double
    
    // Schijf van vijf
    var isSchijfVanVijf: Bool
    var schijfVanVijfColumn: SchijfVanVijfColumn?
    var schijfVanVijfCategory: SchijfVanVijfCategory?
    
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
    
    init(id: UUID, date: Date? = nil, meal: Meal? = nil, energy: Double, carbohydrates: Double, protein: Double, fat: Double) {
        self.id = id
        self.date = date
        self.meal = meal
        self.energy = energy
        self.carbohydrates = carbohydrates
        self.protein = protein
        self.fat = fat
        
        self.isSchijfVanVijf = false
    }
    
    init(guess: Eetmeter.Guess, date: Date?) {
        let meal = Meal(rawValue: guess.period)
        
        self.id = guess.id
        self.date = date
        self.meal = meal
        self.energy = guess.energy
        self.carbohydrates = guess.carbs
        self.protein = guess.protein
        self.fat = guess.fat
        
        self.isSchijfVanVijf = false
    }
}
