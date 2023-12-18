
import Foundation

/**
 These definitions are based on data from Voedingcentrum for me specifically, could use some configuration lol.
 */

struct NutritionalTarget {
    let dangerMin: Double?
    let min: Double?
    let max: Double?
    let dangerMax: Double?
    let per1000kcal: Bool
    
    init(min: Double) {
        self.min = min
        self.dangerMin = min
        self.max = nil
        self.dangerMax = nil
        self.per1000kcal = false
    }
    
    init(min: Double, max: Double) {
        self.dangerMin = min
        self.min = min
        self.max = max
        self.dangerMax = max
        self.per1000kcal = false
    }
    
    init(dangerMin: Double, min: Double) {
        self.dangerMin = dangerMin
        self.min = min
        self.max = nil
        self.dangerMax = nil
        self.per1000kcal = false
    }
    
    init(dangerMin: Double, min: Double, max: Double) {
        self.dangerMin = dangerMin
        self.min = min
        self.max = max
        self.dangerMax = max
        self.per1000kcal = false
    }
    
    init(min: Double, max: Double, dangerMax: Double) {
        self.dangerMin = min
        self.min = min
        self.max = max
        self.dangerMax = dangerMax
        self.per1000kcal = false
    }
    
    init(dangerMin: Double?, min: Double?, max: Double?, dangerMax: Double?, per1000kcal: Bool = false) {
        self.dangerMin = min
        self.min = min
        self.max = max
        self.dangerMax = dangerMax
        self.per1000kcal = per1000kcal
    }
}

struct NutritionalTargets {
    let columnTargets: [SchijfVanVijfColumn:NutritionalTarget] = [
        .vegetables: NutritionalTarget(min: 250),
        .fruits: NutritionalTarget(min: 200),
        .fats: NutritionalTarget(min: 65),
        .fishAndMeat: NutritionalTarget(min: 100),
        .nuts: NutritionalTarget(min: 25),
        .dairy: NutritionalTarget(min: 300, max: 450),
        .cheese: NutritionalTarget(min: 40),
        .bread: NutritionalTarget(min: 210, max: 280),
        .grainAndPotatos: NutritionalTarget(min: 200, max: 350),
        .drinks: NutritionalTarget(min: 1500, max: 2000)
    ]
    
    let targets: [KeyPath<Nutritional, Double?>:NutritionalTarget] = [
        // Macronutrients
        \.fiber: NutritionalTarget(dangerMin: 9.6, min: 14.2, max: nil, dangerMax: nil, per1000kcal: true),
        \.fatSaturated: NutritionalTarget(dangerMin: nil, min: nil, max: 11.1, dangerMax: 14.4, per1000kcal: true),

        // Vitamins
        \.vitaminA: NutritionalTarget(dangerMin: 615, min: 800, max: 3000),
        \.thiamin: NutritionalTarget(dangerMin: 0.3, min: 0.4, max: nil, dangerMax: nil, per1000kcal: true),
        \.riboflavin: NutritionalTarget(dangerMin: 1.3, min: 1.6, max: nil, dangerMax: nil),
        \.niacin: NutritionalTarget(dangerMin: 5.4, min: 6.7, max: nil, dangerMax: nil, per1000kcal: true),
        \.vitaminB6: NutritionalTarget(dangerMin: 1.1, min: 1.5, max: 12),
        \.vitaminB12: NutritionalTarget(dangerMin: 2, min: 2.8, max: nil, dangerMax: nil),
        \.vitaminC: NutritionalTarget(dangerMin: 60, min: 80, max: 2000, dangerMax: nil),
        \.vitaminD: NutritionalTarget(dangerMin: nil, min: 3, max: 100, dangerMax: 100),
        \.vitaminE: NutritionalTarget(dangerMin: nil, min: nil, max: nil, dangerMax: 300),
        \.folate: NutritionalTarget(dangerMin: 200, min: 300, max: 2000),

        // Minerals
        \.calcium: NutritionalTarget(dangerMin: 860, min: 1000, max: 2500),
        \.iron: NutritionalTarget(dangerMin: 6, min: 11, max: 25),
        \.magnesium: NutritionalTarget(dangerMin: 300, min: 350, max: 850, dangerMax: nil),
        \.phosphorus: NutritionalTarget(dangerMin: nil, min: nil, max: nil, dangerMax: 3000),
        \.potassium: NutritionalTarget(dangerMin: 1600, min: 3500),
        \.sodium: NutritionalTarget(dangerMin: 575, min: 1500, max: 2400),
        \.zinc: NutritionalTarget(dangerMin: 6.4, min: 9, max: 25),

        // Ultratrace Minerals
        \.iodine: NutritionalTarget(dangerMin: 100, min: 150, max: 600),
        \.selenium: NutritionalTarget(dangerMin: 15, min: 15, max: 255, dangerMax: 255)
    ]
}
