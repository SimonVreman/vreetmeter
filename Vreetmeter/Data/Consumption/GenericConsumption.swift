
import Foundation

class GenericConsumption: Consumption {
    var id: UUID
    var date: Date?
    var meal: Meal?
    var amount: Double
    var grams: Double?
    var energy: Double
    var carbohydrates: Double
    var protein: Double
    var fat: Double
    var productName: String
    var unitName: String
    var productUnitId: UUID
    
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
    
    init(consumption: Eetmeter.Consumption, grams: Double, date: Date?) {
        let meal = Meal(rawValue: consumption.period)
        
        self.id = consumption.id
        self.date = date
        self.meal = meal
        self.amount = consumption.amount
        self.grams = grams
        self.energy = consumption.energie
        self.carbohydrates = consumption.koolhydraten
        self.protein = consumption.eiwit
        self.fat = consumption.vet
        self.productName = consumption.productName
        self.unitName = consumption.unitName
        self.productUnitId = consumption.productUnitId
        
        let column = SchijfVanVijfColumn(rawValue: consumption.svvColumn)
        self.schijfVanVijfColumn = column
        self.schijfVanVijfCategory = column != nil ? SchijfVanVijfCategory(column: column!) : nil
        self.isSchijfVanVijf = column != nil
    }
}
