
import Foundation

protocol Product: AnyObject, Hashable, NutritionalImmutable {
    var id: UUID { get }
}
