
import SwiftUI

@Observable class EetmeterAPI {
    var favorites: [Eetmeter.Favorite]
    var loggedIn: Bool { self.client.loggedIn }
    private let cache: EetmeterCache
    private let client: EetmeterClient
    private var dayNotes: [Date:Eetmeter.DayNote]
    private var dayMetas: [Date:Eetmeter.DayMeta]
    
    init() {
        self.dayMetas = [:]
        self.favorites = []
        self.dayNotes = [:]
        self.cache = EetmeterCache()
        self.client = EetmeterClient()
        
        if (self.loggedIn) { Task { try await self.fetchFavorites() } }
    }
    
    func fetchDayConsumptions(date: Date, tryCache: Bool = true) async throws -> Eetmeter.DayConsumptions {
        if tryCache {
            let cached = self.cache.getDayConsumptions(date: date)
            if (cached != nil) { return cached! }
        }
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyyMMdd"
        let formattedDate = dateFormatter.string(from: date)
        
        let urlRequest = self.client.makeRequest("consumption/" + formattedDate + "/" + formattedDate)
        
        let data = try await self.client.requestData(urlRequest)
        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .lowerCaseFirstCharacter
        decoder.dateDecodingStrategy = .eetmeterDate
        let decoded = try decoder.decode(Eetmeter.DayConsumptions.self, from: data)
        self.cache.setDayConsumptions(consumptions: decoded)
        return decoded
    }
    
    func fetchDayMeta(date: Date) async throws -> Eetmeter.DayMeta {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyyMMdd"
        let formattedDate = dateFormatter.string(from: date)
        
        let urlRequest = self.client.makeRequest("consumptiondaynote/" + formattedDate)
        
        let data = try await self.client.requestData(urlRequest)
        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .lowerCaseFirstCharacter
        decoder.dateDecodingStrategy = .eetmeterDate
        var decoded = try decoder.decode(Eetmeter.DayNote?.self, from: data)
        
        if decoded == nil {
            decoded = Eetmeter.DayNote(id: UUID(), consumptionDate: date, note: "")
        }
        
        let meta: Eetmeter.DayMeta = try decodeVreetmeterMeta(input: decoded!.note) ?? Eetmeter.DayMeta(id: UUID(), guesses: [])
        let note = decoded!
        await MainActor.run {
            self.dayNotes[date] = note
            self.dayMetas[date] = meta
        }
        return meta
    }
    
    func fetchFavorites() async throws {
        let urlRequest = self.client.makeRequest("userfavorite")
        
        let data = try await self.client.requestData(urlRequest)
        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .lowerCaseFirstCharacter
        let decoded = try decoder.decode(Eetmeter.Favorites.self, from: data)
        
        await MainActor.run { self.favorites = decoded.items }
    }
    
    func fetchCombinedProducts() async throws -> [Eetmeter.CombinedProduct] {
        let urlRequest = self.client.makeRequest("combinedproduct")
        
        let data = try await self.client.requestData(urlRequest)
        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .lowerCaseFirstCharacter
        let decoded = try decoder.decode(Eetmeter.CombinedProducts.self, from: data)
        return decoded.items
    }
    
    func searchConsumptions(query: String) async throws -> [Eetmeter.ConsumptionSearchResult] {
        let urlRequest = self.client.makeRequest("search/31", query: [URLQueryItem(name: "query", value: query)])
        
        let data = try await self.client.requestData(urlRequest)
        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .lowerCaseFirstCharacter
        return try decoder.decode([Eetmeter.ConsumptionSearchResult].self, from: data)
    }
    
    func getByBarcode(barcode: String) async throws -> Eetmeter.BrandProduct {
        let cached = self.cache.getProduct(ean: barcode)
        if (cached != nil) { return cached! }
        
        let urlRequest = self.client.makeRequest("brandproduct/ean/" + barcode)
        
        let data = try await self.client.requestData(urlRequest)
        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .lowerCaseFirstCharacter
        let result = try decoder.decode(Eetmeter.BrandProduct.self, from: data)
        self.cache.setProduct(product: result)
        return result
    }
    
    func getBrandProduct(id: UUID) async throws -> Eetmeter.BrandProduct {
        let cached: Eetmeter.BrandProduct? = self.cache.getProduct(id: id)
        if (cached != nil) { return cached! }
        
        let urlRequest = self.client.makeRequest("brandproduct/" + id.uuidString)
        
        let data = try await self.client.requestData(urlRequest)
        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .lowerCaseFirstCharacter
        let result = try decoder.decode(Eetmeter.BrandProduct.self, from: data)
        self.cache.setProduct(product: result)
        return result
    }
    
    func getProduct(id: UUID, isUnit: Bool = false) async throws -> Eetmeter.Product {
        let cached: Eetmeter.Product? = isUnit ? self.cache.getProductByUnit(id: id) : self.cache.getProduct(id: id)
        if (cached != nil) { return cached! }
        
        let urlRequest = self.client.makeRequest("product/" + (isUnit ? "unit/" : "") + id.uuidString)
        
        let data = try await self.client.requestData(urlRequest)
        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .lowerCaseFirstCharacter
        let result = try decoder.decode(Eetmeter.Product.self, from: data)
        self.cache.setProduct(product: result)
        return result
    }
    
    func getBaseProduct(id: UUID, isUnit: Bool = false) async throws -> Eetmeter.BaseProduct {
        let cached: Eetmeter.BaseProduct? = isUnit ? self.cache.getProductByUnit(id: id) : self.cache.getProduct(id: id)
        if (cached != nil) { return cached! }
        
        let urlRequest = self.client.makeRequest("baseproduct/" + (isUnit ? "unit/" : "") + id.uuidString)
        
        let data = try await self.client.requestData(urlRequest)
        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .lowerCaseFirstCharacter
        let result = try decoder.decode(Eetmeter.BaseProduct.self, from: data)
        self.cache.setProduct(product: result)
        return result
    }
    
    func getUnit(id: UUID) async throws -> Eetmeter.ProductUnit {
        let cached = self.cache.getUnit(id: id)
        if (cached != nil) { return cached! }
        
        let product = try await self.getProduct(id: id, isUnit: true)
        let units = product.preparationVariants.flatMap { v in v.product.units }
        return units.first { $0.id == id }!
    }
    
    func saveDayMeta(meta: Eetmeter.DayMeta, date: Date) async throws {
        var urlRequest = self.client.makeRequest("consumptiondaynote")
        urlRequest.httpMethod = "PUT"
        urlRequest.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let encoder = JSONEncoder()
        var note = dayNotes[date] ?? Eetmeter.DayNote(id: UUID(), consumptionDate: date, note: "")
        let match = note.note.firstMatch(of: META_PATTERN)
        if (match != nil) {
            note.note = note.note.replacingCharacters(in: match!.range, with: "")
        }
        note.note += try encodeVreetmeterMeta(input: meta)
        dayNotes[date] = note
        dayMetas[date] = meta
        
        encoder.dateEncodingStrategy = .eetmeterMidnightDate
        encoder.keyEncodingStrategy = .upperCaseFirstCharacter
        urlRequest.httpBody = try encoder.encode(note)
        
        let _ = try await self.client.requestData(urlRequest)
    }
    
    func saveProduct(update: Eetmeter.ProductUpdate) async throws {
        var urlRequest = self.client.makeRequest("consumption")
        urlRequest.httpMethod = "PUT"
        urlRequest.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .eetmeterDate
        urlRequest.httpBody = try encoder.encode(update)
        
        let _ = try await self.client.requestData(urlRequest)
    }
    
    func saveCombinedProduct(id: UUID, update: Eetmeter.CombinedProductUpdate) async throws {
        var urlRequest = self.client.makeRequest("combinedproduct/" + id.uuidString + "/addtodiary")
        urlRequest.httpMethod = "POST"
        urlRequest.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .eetmeterDate
        urlRequest.httpBody = try encoder.encode(update)
        
        let _ = try await self.client.requestData(urlRequest)
    }
    
    func saveGuess(update: Eetmeter.GuessUpdate) async throws {
        var dayMeta = self.dayMetas[update.date]
        if (dayMeta == nil) {
            dayMeta = try await self.fetchDayMeta(date: update.date)
        }
        
        let index = dayMeta!.guesses.firstIndex { g in g.id == update.id }
        if (index == nil) {
            dayMeta!.guesses.append(Eetmeter.Guess(
                id: update.id ?? UUID(),
                period: update.period,
                energy: update.energy,
                protein: update.protein,
                fat: update.fat,
                carbs: update.carbs
            ))
        } else {
            var guess = dayMeta!.guesses[index!]
            guess.carbs = update.carbs
            guess.fat = update.fat
            guess.protein = update.protein
            guess.energy = update.energy
            dayMeta!.guesses[index!] = guess
        }
        
        return try await self.saveDayMeta(meta: dayMeta!, date: update.date)
    }
    
    func saveFavorite(update: Eetmeter.FavoriteUpdate) async throws {
        var urlRequest = self.client.makeRequest("userfavorite")
        urlRequest.httpMethod = "PUT"
        urlRequest.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let encoder = JSONEncoder()
        encoder.keyEncodingStrategy = .upperCaseFirstCharacter
        urlRequest.httpBody = try encoder.encode(update)
        
        let data = try await self.client.requestData(urlRequest)
        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .lowerCaseFirstCharacter
        let result = try decoder.decode(Eetmeter.Favorite.self, from: data)
        await MainActor.run { self.favorites.append(result) }
    }
    
    func deleteGuess(id: UUID, date: Date) async throws {
        var dayMeta = self.dayMetas[date]
        if (dayMeta == nil) {
            dayMeta = try await self.fetchDayMeta(date: date)
        }
        
        let index = dayMeta!.guesses.firstIndex { g in g.id == id }
        if (index == nil) { return }
        dayMeta!.guesses.remove(at: index!)
        return try await self.saveDayMeta(meta: dayMeta!, date: date)
    }
    
    func deleteProduct(id: UUID) async throws {
        var urlRequest = self.client.makeRequest("consumption/" + id.uuidString)
        urlRequest.httpMethod = "DELETE"
        let _ = try await self.client.requestData(urlRequest)
    }
    
    func deleteFavorite(id: UUID) async throws {
        var urlRequest = self.client.makeRequest("userfavorite/" + id.uuidString)
        urlRequest.httpMethod = "DELETE"
        let _ = try await self.client.requestData(urlRequest)
        await MainActor.run { self.favorites = self.favorites.filter { $0.id != id } }
    }

    func login(email: String, password: String) async throws {
        var urlRequest = self.client.makeRequest("account/credentials")
        urlRequest.httpMethod = "POST"
        urlRequest.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let encoder = JSONEncoder()
        let deviceId = UUID().uuidString
        urlRequest.httpBody = try encoder.encode(Eetmeter.Login(deviceId: deviceId, emailAddress: email, password: password))
        
        let data = try await self.client.requestData(urlRequest)
        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .lowerCaseFirstCharacter
        let decoded = try decoder.decode(Eetmeter.Account.self, from: data)
        let token = decoded.token + ":" + deviceId
        
        await MainActor.run {
            self.client.login(token: token)
        }
        
        try await fetchFavorites()
    }
    
    func logout() {
        self.client.logout()
    }
}
