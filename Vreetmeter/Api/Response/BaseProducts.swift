
import Foundation

extension Eetmeter {
    struct BaseProduct: Identifiable, Codable, Hashable {
        let id: UUID
        let name: String
        let products: [Product]
    }
}
