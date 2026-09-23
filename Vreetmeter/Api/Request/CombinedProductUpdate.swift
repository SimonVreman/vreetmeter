
import Foundation

extension Eetmeter {
    nonisolated struct CombinedProductUpdate: Encodable {
        var amount: Double
        var period: Int
        var consumptionDate: Date
    }
}
