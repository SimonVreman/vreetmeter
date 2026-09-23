
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
        case unitRegularProductMapping = "unitRegularProduct"
        case dayConsumptions = "dayConsumptions"
        case dayMeta = "dayMeta"
    }
    
    private let cache: Storage<String, Data>?
    private let decoder = JSONDecoder()
    private let encoder = JSONEncoder()
    private let separator = "."
    private let versionKey = "eetmeter.cache.version"
    
    // Bump when cached models change shape to invalidate existing entries
    private static let version = 3
    
    init() {
        self.cache = try? Storage(
            diskConfig: DiskConfig(
                name: "ProductCache",
                expiry: Expiry.seconds(60 * 60 * 24 * 30 * 3),
                maxSize: 1000 * 500
            ),
            memoryConfig: MemoryConfig(expiry: Expiry.seconds(60 * 60)),
            fileManager: .default,
            transformer: TransformerFactory.forData()
        )
        
        // Drop everything cached by an older version of the data models
        if UserDefaults.standard.integer(forKey: self.versionKey) != Self.version {
            try? self.cache?.removeAll()
            UserDefaults.standard.set(Self.version, forKey: self.versionKey)
        }
        try? self.cache?.removeExpiredObjects()
    }
    
    func getProduct(id: UUID) -> Eetmeter.Product? {
        guard let data = self.object(forKey: self.getKey(prefix: .regular, id: id.uuidString)) else { return nil }
        return try? self.decoder.decode(Eetmeter.Product.self, from: data)
    }
    
    func getProduct(id: UUID) -> Eetmeter.BaseProduct? {
        guard let data = self.object(forKey: self.getKey(prefix: .base, id: id.uuidString)) else { return nil }
        return try? self.decoder.decode(Eetmeter.BaseProduct.self, from: data)
    }
    
    func getProduct(id: UUID) -> Eetmeter.BrandProduct? {
        guard let data = self.object(forKey: self.getKey(prefix: .brand, id: id.uuidString)) else { return nil }
        return try? self.decoder.decode(Eetmeter.BrandProduct.self, from: data)
    }
    
    func getProduct(ean: String) -> Eetmeter.BrandProduct? {
        guard let uuid = self.getUUID(key: self.getKey(prefix: .barcodeMapping, id: ean)) else { return nil }
        return getProduct(id: uuid)
    }
    
    func getProductByUnit(id: UUID) -> Eetmeter.Product? {
        guard let productId = self.getUUID(key: self.getKey(prefix: .unitRegularProductMapping, id: id.uuidString)),
              let product: Eetmeter.Product = self.getProduct(id: productId) else { return nil }
        
        // Only a hit if the product actually offers this unit
        let hasUnit = product.preparationVariants.contains { v in v.product.units.contains { $0.id == id } }
        return hasUnit ? product : nil
    }
    
    func getProductByUnit(id: UUID) -> Eetmeter.BaseProduct? {
        guard let baseProductId = self.getUUID(key: self.getKey(prefix: .unitProductMapping, id: id.uuidString)) else { return nil }
        return self.getProduct(id: baseProductId)
    }
    
    func getUnit(id: UUID) -> Eetmeter.ProductUnit? {
        guard let data = self.object(forKey: self.getKey(prefix: .unit, id: id.uuidString)) else { return nil }
        return try? self.decoder.decode(Eetmeter.ProductUnit.self, from: data)
    }
    
    func getDayConsumptions(date: Date) -> Eetmeter.DayConsumptions? {
        let key = self.getDateKey(date: date)
        guard let data = self.object(forKey: self.getKey(prefix: .dayConsumptions, id: key)) else { return nil }
        return try? self.decoder.decode(Eetmeter.DayConsumptions.self, from: data)
    }
    
    func getDayMeta(date: Date) -> Eetmeter.DayMeta? {
        let key = self.getDateKey(date: date)
        guard let data = self.object(forKey: self.getKey(prefix: .dayMeta, id: key)) else { return nil }
        return try? self.decoder.decode(Eetmeter.DayMeta.self, from: data)
    }
    
    func setProduct(product: Eetmeter.Product) {
        guard let data = try? self.encoder.encode(product) else { return }
        try? self.cache?.setObject(data, forKey: self.getKey(prefix: .regular, id: product.id.uuidString))
        
        // Cache units, and map each unit back to this product
        let units = product.preparationVariants.flatMap { v in v.product.units }
        let productUUID = Data(product.id.uuidString.utf8)
        for unit in units {
            self.setUnit(unit: unit)
            try? self.cache?.setObject(productUUID, forKey: self.getKey(prefix: .unitRegularProductMapping, id: unit.id.uuidString))
        }
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
        try? self.cache?.setObject(data, forKey: self.getKey(prefix: .dayConsumptions, id: self.getDateKey(date: consumptions.startDate)))
    }
    
    func setDayMeta(meta: Eetmeter.DayMeta, date: Date) {
        guard let data = try? self.encoder.encode(meta) else { return }
        try? self.cache?.setObject(data, forKey: self.getKey(prefix: .dayMeta, id: self.getDateKey(date: date)))
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

    // Storage.object(forKey:) happily returns expired entries, so check expiry ourselves
    private func object(forKey key: String) -> Data? {
        guard let entry = try? self.cache?.entry(forKey: key) else { return nil }
        if entry.expiry.isExpired {
            try? self.cache?.removeObject(forKey: key)
            return nil
        }
        return entry.object
    }
    
    private func getUUID(key: String) -> UUID? {
        guard let data = self.object(forKey: key) else { return nil }
        let uuidString = String(decoding: data, as: UTF8.self)
        return UUID(uuidString: uuidString)
    }
    
    private func getDateKey(date: Date) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyyMMdd"
        return dateFormatter.string(from: date)
    }
    
    private func getKey(prefix: Prefix, id: String) -> String {
        return prefix.rawValue + self.separator + id
    }
}
