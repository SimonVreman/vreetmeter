
import Foundation

extension Eetmeter {
    struct ConsumptionSearchResult: Identifiable, Decodable, Hashable {
        var id: UUID
        var brandName: String?
        var productName: String
        var type: Int
    }
}
