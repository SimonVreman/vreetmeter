
import Foundation

extension Eetmeter {
    struct Product: Codable, Hashable, Identifiable, EetmeterNutritional {
        let id: UUID
        let baseProductId: UUID?
        let baseProductName: String?
        let preparationVariants: [PreparationVariant]
        
        var alcohol: Double?
        var calcium: Double?
        var eiwit: Double?
        var eiwitPlantaardig: Double?
        var energie: Double?
        var foliumzuur: Double?
        var fosfor: Double?
        var iJzer: Double?
        var jodium: Double?
        var kalium: Double?
        var koolhydraten: Double?
        var magnesium: Double?
        var natrium: Double?
        var nicotinezuur: Double?
        var selenium: Double?
        var suikers: Double?
        var verzadigdVet: Double?
        var vet: Double?
        var vezels: Double?
        var vitamineA: Double?
        var vitamineB1: Double?
        var vitamineB12: Double?
        var vitamineB2: Double?
        var vitamineB6: Double?
        var vitamineC: Double?
        var vitamineD: Double?
        var vitamineE: Double?
        var water: Double?
        var zink: Double?
        var zout: Double?
    }
    
    struct PreparationVariant: Codable, Hashable {
        let id: UUID
        let name: String
        let sortOrder: Int
        let product: PreparationVariantProduct
    }
    
    struct PreparationVariantProduct: Codable, Hashable, EetmeterNutritional {
        let baseProductId: UUID?
        let baseProductName: String?
        let preparationMethod: PreparationMethod
        let units: [ProductUnit]
        
        var alcohol: Double?
        var calcium: Double?
        var eiwit: Double?
        var eiwitPlantaardig: Double?
        var energie: Double?
        var foliumzuur: Double?
        var fosfor: Double?
        var iJzer: Double?
        var jodium: Double?
        var kalium: Double?
        var koolhydraten: Double?
        var magnesium: Double?
        var natrium: Double?
        var nicotinezuur: Double?
        var selenium: Double?
        var suikers: Double?
        var verzadigdVet: Double?
        var vet: Double?
        var vezels: Double?
        var vitamineA: Double?
        var vitamineB1: Double?
        var vitamineB12: Double?
        var vitamineB2: Double?
        var vitamineB6: Double?
        var vitamineC: Double?
        var vitamineD: Double?
        var vitamineE: Double?
        var water: Double?
        var zink: Double?
        var zout: Double?
    }
    
    struct PreparationMethod: Codable, Hashable {
        let id: UUID
        let name: String
        let isRaw: Bool
    }
    
    struct ProductUnit: Codable, Hashable, Identifiable {
        let displayName: String
        let gramsPerUnit: Int
        let id: UUID
        let isObsolete: Bool
        let isTussendoortje: Bool
        let productId: UUID
        let productName: String
        let unitId: UUID
        let unitName: String
    }
}

protocol EetmeterNutritional {
    var alcohol: Double? { get }
    var calcium: Double? { get }
    var eiwit: Double? { get }
    var eiwitPlantaardig: Double? { get }
    var energie: Double? { get }
    var foliumzuur: Double? { get }
    var fosfor: Double? { get }
    var iJzer: Double? { get }
    var jodium: Double? { get }
    var kalium: Double? { get }
    var koolhydraten: Double? { get }
    var magnesium: Double? { get }
    var natrium: Double? { get }
    var nicotinezuur: Double? { get }
    var selenium: Double? { get }
    var suikers: Double? { get }
    var verzadigdVet: Double? { get }
    var vet: Double? { get }
    var vezels: Double? { get }
    var vitamineA: Double? { get }
    var vitamineB1: Double? { get }
    var vitamineB12: Double? { get }
    var vitamineB2: Double? { get }
    var vitamineB6: Double? { get }
    var vitamineC: Double? { get }
    var vitamineD: Double? { get }
    var vitamineE: Double? { get }
    var water: Double? { get }
    var zink: Double? { get }
    var zout: Double? { get }
}
