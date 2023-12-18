
import Cache
import SwiftUI

class EetmeterCache {
    private enum Prefix: String {
        case regular = "product"
        case base = "baseProduct"
        case brand = "brandProduct"
        case unit = "productUnit"
        case barcodeMapping = "barcode"
        case unitProductMapping = "unitProduct"
        case dayConsumptions = "dayConsumptions"
    }
    
    private let cache: Storage<String, Data>?
    private let decoder = JSONDecoder()
    private let encoder = JSONEncoder()
    private let separator = "."
    
    init() {
        self.cache = try? Storage(
            diskConfig: DiskConfig(
                name: "ProductCache",
                expiry: Expiry.seconds(60 * 60 * 24 * 30 * 3),
                maxSize: 1000 * 500
            ),
            memoryConfig: MemoryConfig(expiry: Expiry.seconds(60 * 60)),
            transformer: TransformerFactory.forData()
        )
    }
    
    func getProduct(id: UUID) -> Eetmeter.Product? {
        guard let data = try? self.cache?.object(forKey: self.getKey(prefix: .regular, id: id.uuidString)) else { return nil }
        return try? self.decoder.decode(Eetmeter.Product.self, from: data)
    }
    
    func getProduct(id: UUID) -> Eetmeter.BaseProduct? {
        guard let data = try? self.cache?.object(forKey: self.getKey(prefix: .base, id: id.uuidString)) else { return nil }
        return try? self.decoder.decode(Eetmeter.BaseProduct.self, from: data)
    }
    
    func getProduct(id: UUID) -> Eetmeter.BrandProduct? {
        guard let data = try? self.cache?.object(forKey: self.getKey(prefix: .brand, id: id.uuidString)) else { return nil }
        return try? self.decoder.decode(Eetmeter.BrandProduct.self, from: data)
    }
    
    func getProduct(ean: String) -> Eetmeter.BrandProduct? {
        guard let uuid = self.getUUID(key: self.getKey(prefix: .barcodeMapping, id: ean)) else { return nil }
        return getProduct(id: uuid)
    }
    
    func getProductByUnit(id: UUID) -> Eetmeter.Product? {
        guard let unit = self.getUnit(id: id) else { return nil }
        return self.getProduct(id: unit.productId)
    }
    
    func getProductByUnit(id: UUID) -> Eetmeter.BaseProduct? {
        guard let baseProductId = self.getUUID(key: self.getKey(prefix: .unitProductMapping, id: id.uuidString)) else { return nil }
        return self.getProduct(id: baseProductId)
    }
    
    func getUnit(id: UUID) -> Eetmeter.ProductUnit? {
        guard let data = try? self.cache?.object(forKey: self.getKey(prefix: .unit, id: id.uuidString)) else { return nil }
        return try? self.decoder.decode(Eetmeter.ProductUnit.self, from: data)
    }
    
    func getDayConsumptions(date: Date) -> Eetmeter.DayConsumptions? {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyyMMdd"
        let key = dateFormatter.string(from: date)
        guard let data = try? self.cache?.object(forKey: self.getKey(prefix: .dayConsumptions, id: key)) else { return nil }
        return try? self.decoder.decode(Eetmeter.DayConsumptions.self, from: data)
    }
    
    func setProduct(product: Eetmeter.Product) {
        guard let data = try? self.encoder.encode(product) else { return }
        try? self.cache?.setObject(data, forKey: self.getKey(prefix: .regular, id: product.id.uuidString))
        
        // Cache units
        let units = product.preparationVariants.flatMap { v in v.product.units }
        for unit in units { self.setUnit(unit: unit) }
    }

    func setProduct(product: Eetmeter.BaseProduct) {
        guard let data = try? self.encoder.encode(product) else { return }
        try? self.cache?.setObject(data, forKey: self.getKey(prefix: .base, id: product.id.uuidString))
        
        // Cache units
        let units = product.products.flatMap { p in p.preparationVariants.flatMap { v in v.product.units } }
        let baseUUID = Data(product.id.uuidString.utf8)
        for unit in units {
            self.setUnit(unit: unit)
            try? self.cache?.setObject(baseUUID, forKey: self.getKey(prefix: .unitProductMapping, id: unit.id.uuidString))
        }
    }
    
    func setDayConsumptions(consumptions: Eetmeter.DayConsumptions) {
        guard let data = try? self.encoder.encode(consumptions) else { return }
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyyMMdd"
        let key = dateFormatter.string(from: consumptions.startDate)
        try? self.cache?.setObject(data, forKey: self.getKey(prefix: .dayConsumptions, id: key))
    }
    
    func setProduct(product: Eetmeter.BrandProduct) {
        guard let data = try? self.encoder.encode(product) else { return }
        try? self.cache?.setObject(data, forKey: self.getKey(prefix: .brand, id: product.id.uuidString))

        // Also cache barcode to id map
        let uuidData = Data(product.id.uuidString.utf8)
        try? self.cache?.setObject(uuidData, forKey: self.getKey(prefix: .barcodeMapping, id: product.ean))
        
        // Cache units
        let units = product.product.preparationVariants.flatMap { v in v.product.units }
        for unit in units { self.setUnit(unit: unit) }
    }
    
    func setUnit(unit: Eetmeter.ProductUnit) {
        guard let unitData = try? self.encoder.encode(unit) else { return }
        try? self.cache?.setObject(unitData, forKey: self.getKey(prefix: .unit, id: unit.id.uuidString))
    }

    private func getUUID(key: String) -> UUID? {
        guard let data = try? self.cache?.object(forKey: key) else { return nil }
        let uuidString = String(decoding: data, as: UTF8.self)
        return UUID(uuidString: uuidString)
    }
    
    private func getKey(prefix: Prefix, id: String) -> String {
        return prefix.rawValue + self.separator + id
    }
}
