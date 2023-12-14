
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
}
