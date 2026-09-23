
import Foundation

extension Eetmeter {
    nonisolated struct BaseProduct: Identifiable, Codable, Hashable {
        let id: UUID
        let name: String
        let products: [Product]
    }
}
