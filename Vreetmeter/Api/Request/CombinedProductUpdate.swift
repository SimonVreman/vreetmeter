
import Foundation

extension Eetmeter {
    struct CombinedProductUpdate: Encodable {
        var amount: Double
        var period: Int
        var consumptionDate: Date
    }
}
