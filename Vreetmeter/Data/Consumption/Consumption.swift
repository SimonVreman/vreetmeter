
import Foundation

protocol Consumption: AnyObject, Nutritional, SchijfVanVijf {
    var id: UUID { get }
    var date: Date? { get }
    var meal: Meal? { get }
}
