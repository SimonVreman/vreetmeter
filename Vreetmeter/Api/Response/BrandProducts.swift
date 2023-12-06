
import Foundation

extension Eetmeter {
    struct BrandProduct: Identifiable, Hashable, Codable, EetmeterNutritional {
        let id: UUID
        let product: Product
        let alcohol: Double?
        let brandName: String
        let calcium: Double?
        let eiwit: Double?
        let eiwitPlantaardig: Double?
        let energie: Double?
        let foliumzuur: Double?
        let fosfor: Double?
        let iJzer: Double?
        let jodium: Double?
        let kalium: Double?
        let koolhydraten: Double?
        let magnesium: Double?
        let natrium: Double?
        let nicotinezuur: Double?
        let productGroupId: UUID
        let productName: String
        let preparedToRawCorrectionFactor: Double?
        let selenium: Double?
        let suikers: Double?
        let verzadigdVet: Double?
        let vet: Double?
        let vezels: Double?
        let vitamineA: Double?
        let vitamineB1: Double?
        let vitamineB12: Double?
        let vitamineB2: Double?
        let vitamineB6: Double?
        let vitamineC: Double?
        let vitamineD: Double?
        let vitamineE: Double?
        let water: Double?
        let weightGainFactor: Double?
        let zink: Double?
        let zout: Double?
        let ean: String
    }
}
