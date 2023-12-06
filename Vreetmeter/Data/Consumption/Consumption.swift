
import Foundation

protocol Consumption: AnyObject, Nutritional {
    var id: UUID { get }
    var date: Date? { get }
    var meal: Meal? { get }
}
