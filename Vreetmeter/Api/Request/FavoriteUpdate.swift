
import Foundation

extension Eetmeter {
    nonisolated struct FavoriteUpdate: Encodable {
        var amount: Double
        var productUnitID: UUID?
        var brandProductID: UUID?
        var combinedProductID: UUID?
    }
}
