
import Foundation

extension Eetmeter {
    struct FavoriteUpdate: Encodable {
        var amount: Double
        var productUnitID: UUID?
        var brandProductID: UUID?
        var combinedProductID: UUID?
    }
}
