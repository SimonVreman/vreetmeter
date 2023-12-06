
import Foundation

class BrandConsumption: Consumption {
    var id: UUID
    var date: Date?
    var meal: Meal?
    var amount: Double
    var energy: Double
    var carbohydrates: Double
    var protein: Double
    var fat: Double
    var productName: String
    var brandName: String
    var unitName: String
    var productUnitId: UUID
    var brandProductId: UUID
    
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
    
    init(id: UUID, date: Date? = nil, meal: Meal? = nil, amount: Double, energy: Double, carbohydrates: Double, protein: Double, fat: Double, productName: String, brandName: String, unitName: String, productUnitId: UUID, brandProductId: UUID) {
        self.id = id
        self.date = date
        self.meal = meal
        self.amount = amount
        self.energy = energy
        self.carbohydrates = carbohydrates
        self.protein = protein
        self.fat = fat
        self.productName = productName
        self.brandName = brandName
        self.unitName = unitName
        self.productUnitId = productUnitId
        self.brandProductId = brandProductId
    }
    
    init(consumption: Eetmeter.Consumption, date: Date?) {
        let meal = Meal(rawValue: consumption.period)
        
        self.id = consumption.id
        self.date = date
        self.meal = meal
        self.amount = consumption.amount
        self.energy = consumption.energie
        self.carbohydrates = consumption.koolhydraten
        self.protein = consumption.eiwit
        self.fat = consumption.vet
        self.productName = consumption.productName
        self.brandName = consumption.brandName
        self.unitName = consumption.unitName
        self.productUnitId = consumption.productUnitId
        self.brandProductId = consumption.brandProductId!
    }
}
