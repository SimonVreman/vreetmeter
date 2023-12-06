
import Foundation

extension Eetmeter {
    struct CombinedProducts: Decodable {
        var items: [CombinedProduct]
    }
    
    struct CombinedProduct: Codable, Identifiable, Hashable {
        var id: UUID
        var name: String
        var numberOfPortions: Int
        var items: [CombinedProductIngredient]
        var meta: Meta?
        
        struct CombinedProductIngredient: Identifiable, Codable, Hashable {
            var id: UUID
            var brandName: String?
            var brandProductId: UUID?
            var productUnitId: UUID
            var productName: String
            var unitName: String
            var amount: Double
        }
        
        struct Meta: Codable, Hashable {
            var portionSizeInGrams: Double
            var caloriesPer100g: Double
            var carbohydratesPer100g: Double
            var proteinPer100g: Double
            var fatPer100g: Double
        }
        
        enum CodingKeys: String, CodingKey {
            case id
            case name
            case numberOfPortions
            case items
        }
        
        init(from decoder: Decoder) throws {
            let container = try decoder.container(keyedBy: CodingKeys.self)
            
            self.id = try container.decode(UUID.self, forKey: .id)
            self.numberOfPortions = try container.decode(Int.self, forKey: .numberOfPortions)
            self.items = try container.decode([CombinedProductIngredient].self, forKey: .items)
            
            let nameAsReceived = try container.decode(String.self, forKey: .name)
            self.meta = try decodeVreetmeterMeta(input: nameAsReceived)
            self.name = nameAsReceived.replacing(META_PATTERN, with: "")
        }
        
        func encode(to encoder: Encoder) throws {
            var container = encoder.container(keyedBy: CodingKeys.self)
            try container.encode(id, forKey: .id)
            try container.encode(numberOfPortions, forKey: .numberOfPortions)
            try container.encode(items, forKey: .items)
            
            var name = self.name
            
            if (meta != nil) {
                name += try encodeVreetmeterMeta(input: meta)
            }
            
            try container.encode(name, forKey: .name)
        }
    }
}
