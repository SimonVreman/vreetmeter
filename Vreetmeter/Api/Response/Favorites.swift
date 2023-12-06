
import Foundation

extension Eetmeter {
    struct Favorites: Decodable {
        var items: [Favorite]
    }
    
    struct Favorite: Identifiable, Decodable, Hashable {
        var id: UUID
        var brandName: String
        var combinedProductId: UUID?
        var brandProductId: UUID?
        var productUnitId: UUID?
        var productName: String
        var unitName: String
    }
}
