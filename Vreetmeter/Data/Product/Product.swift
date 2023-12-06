
import Foundation

protocol Product: AnyObject, NutritionalImmutable {
    var id: UUID { get }
}
