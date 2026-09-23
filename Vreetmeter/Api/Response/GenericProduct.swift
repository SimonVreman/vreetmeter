
import Foundation

extension Eetmeter {
    nonisolated struct GenericProduct: Identifiable, Hashable {
        var id: UUID
        var type: ProductType
        var storedAs: UUID?
        var label: String?
        var sublabel: String?
        var unitId: UUID?
        var amount: Double?
        
        nonisolated enum ProductType {
            case favorite
            case combined
            case general
            case brand
            case unit
        }
    }
}
