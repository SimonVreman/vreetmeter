
import Foundation

/**
 These definitions are based on the "Richtlijnen Schijf van Vijf (2020)" document from Voedingscentrum
 */

protocol SchijfVanVijf {
    var isSchijfVanVijf: Bool { get }
    var schijfVanVijfCategory: SchijfVanVijfCategory? { get }
    var schijfVanVijfColumn: SchijfVanVijfColumn? { get }
}

enum SchijfVanVijfCategory: Int {
    case vegetablesAndFruits = 1
    case oilsAndFats = 2
    case fishMeatDairyAndNuts = 3
    case breadGrainsAndPotatos = 4
    case waterTeaAndCoffee = 5
    
    init(column: SchijfVanVijfColumn) {
        switch column {
        case .vegetables:
            fallthrough
        case .fruits:
            self = .vegetablesAndFruits
        case .fats:
            self = .oilsAndFats
        case .fishAndMeat:
            fallthrough
        case .nuts:
            fallthrough
        case .dairy:
            fallthrough
        case .cheese:
            self = .fishMeatDairyAndNuts
        case .bread:
            fallthrough
        case .grainAndPotatos:
            self = .breadGrainsAndPotatos
        case .drinks:
            self = .waterTeaAndCoffee
        }
    }
}

enum SchijfVanVijfColumn: Int, CaseIterable {
    case vegetables = 1
    case fruits = 2
    case fats = 3
    case fishAndMeat = 4
    case nuts = 5
    case dairy = 6
    case cheese = 7
    case bread = 8
    case grainAndPotatos = 9
    case drinks = 10
    
    func getLabel() -> String {
        switch self {
        case .vegetables: return "Vegetables"
        case .fruits: return "Fruits"
        case .fats: return "Fats"
        case .fishAndMeat: return "Fish and meat"
        case .nuts: return "Nuts"
        case .dairy: return "Dairy"
        case .cheese: return "Cheese"
        case .bread: return "Bread"
        case .grainAndPotatos: return "Grain and potatoes"
        case .drinks: return "Drinks"
        }
    }
    
    func getTarget() -> NutritionalTarget {
        switch self {
        case .vegetables: return NutritionalTarget(dangerMin: 250, min: 250, max: nil, dangerMax: nil)
        case .fruits: return NutritionalTarget(dangerMin: 200, min: 200, max: nil, dangerMax: nil)
        case .fats: return NutritionalTarget(dangerMin: 65, min: 65, max: nil, dangerMax: nil)
        case .fishAndMeat: return NutritionalTarget(dangerMin: 100, min: 100, max: nil, dangerMax: nil)
        case .nuts: return NutritionalTarget(dangerMin: 25, min: 25, max: nil, dangerMax: nil)
        case .dairy: return NutritionalTarget(dangerMin: 300, min: 300, max: 450, dangerMax: nil)
        case .cheese: return NutritionalTarget(dangerMin: 40, min: 40, max: nil, dangerMax: nil)
        case .bread: return NutritionalTarget(dangerMin: 210, min: 210, max: 280, dangerMax: nil)
        case .grainAndPotatos: return NutritionalTarget(dangerMin: 200, min: 200, max: 350, dangerMax: nil)
        case .drinks: return NutritionalTarget(dangerMin: 1500, min: 1500, max: 2000, dangerMax: nil)
        }
    }
}
