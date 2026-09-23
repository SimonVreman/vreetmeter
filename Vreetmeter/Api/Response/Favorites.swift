
import Foundation

extension Eetmeter {
    nonisolated struct Favorites: Decodable {
        var items: [Favorite]
    }
    
    nonisolated struct Favorite: Identifiable, Decodable, Hashable {
        var id: UUID
        var brandName: String
        var combinedProductId: UUID?
        var brandProductId: UUID?
        var productUnitId: UUID?
        var productName: String
        var unitName: String
    }
}
