
import Foundation

extension Eetmeter {
    struct ProductUpdate: Encodable {
        var id: UUID
        var period: Int
        var consumptionDate: Date
        var amount: Double
        var productUnitID: UUID
        var brandProductID: UUID?
    }
}
