
import Foundation

/**
 These definitions are based on data from Voedingcentrum
 */

struct NutritionalTargets {
    let columnTargets: [SchijfVanVijfColumn:(min: Double, max: Double)] = [
        .vegetables: (min: 250, max: 250),
        .fruits: (min: 200, max: 200),
        .fats: (min: 65, max: 65),
        .fishAndMeat: (min: 100, max: 100),
        .nuts: (min: 25, max: 25),
        .dairy: (min: 300, max: 450),
        .cheese: (min: 40, max: 40),
        .bread: (min: 210, max: 280),
        .grainAndPotatos: (min: 200, max: 350),
        .drinks: (min: 1500, max: 2000)
    ]
}
