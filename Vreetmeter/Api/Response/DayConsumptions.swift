
import Foundation

extension Eetmeter {
    struct DayConsumptions: Codable, Equatable {
        var startDate: Date
        var endDate: Date
        var items: [Consumption]
    }

    struct Consumption: Identifiable, Codable, Equatable, Hashable {
        var id: UUID
        var active: Bool
        var amount: Double
        var baseProductSynonymId: UUID?
        var brandName: String
        var brandProductId: UUID?
        var consumptionDate: Date
        var createdDate: Date
        var eiwit: Double
        var eiwitPlantaardig: Double
        var energie: Double
        var fosfor: Double
        var isCombinedProduct: Bool
        var isDaily: Bool
        var koolhydraten: Double
        var natrium: Double
        var ownProductUnitId: UUID?
        var period: Int
        var preparationMethodName: String
        var productName: String
        var productType: Int
        var productUnitId: UUID
        var suikers: Double
        var svvCategory: String
        var svvColumn: Int
        var unitName: String
        var updatedDate: Date
        var verzadigdVet: Double
        var vet: Double
        var vezels: Double
        var webAccountId: UUID
        var zout: Double
    }
}
