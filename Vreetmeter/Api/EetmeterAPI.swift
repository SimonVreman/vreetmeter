
import SwiftUI
import Cache

let API_URL = "https://api3-mijn.voedingscentrum.nl/api/"

class EetmeterAPI: ObservableObject {
    @Published var favorites: [Eetmeter.Favorite]
    @Published var loggedIn: Bool
    let session: URLSession = URLSession.shared
    let cache: EetmeterCache
    let deviceId: String
    var dayNotes: [Date:Eetmeter.DayNote]
    var dayMetas: [Date:Eetmeter.DayMeta]
    var authToken: String?
    
    init() {
        authToken = UserDefaults.standard.object(forKey: "eetmeterAPI.authToken") as? String
        loggedIn = authToken != nil
        dayMetas = [:]
        favorites = []
        dayNotes = [:]
        cache = EetmeterCache()
        deviceId = UUID().uuidString
        
        if (loggedIn) {
            Task {
                try await fetchFavorites()
            }
        }
    }
    
    func fetchDayConsumptions(date: Date) async throws -> Eetmeter.DayConsumptions {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyyMMdd"
        let formattedDate = dateFormatter.string(from: date)
        
        guard let url = URL(string: API_URL + "consumption/" + formattedDate + "/" + formattedDate) else { fatalError("Missing URL") }
        let urlRequest = getUrlRequest(url: url, auth: true)
        
        let (data, _) = try await session.data(for: urlRequest)
        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .lowerCaseFirstCharacter
        decoder.dateDecodingStrategy = .eetmeterDate
        return try decoder.decode(Eetmeter.DayConsumptions.self, from: data)
    }
    
    func fetchDayMeta(date: Date) async throws -> Eetmeter.DayMeta {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyyMMdd"
        let formattedDate = dateFormatter.string(from: date)
        
        guard let url = URL(string: API_URL + "consumptiondaynote/" + formattedDate) else { fatalError("Missing URL") }
        let urlRequest = getUrlRequest(url: url, auth: true)
        
        let (data, _) = try await session.data(for: urlRequest)
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
        guard let url = URL(string: API_URL + "userfavorite") else { fatalError("Missing URL") }
        let urlRequest = getUrlRequest(url: url, auth: true)
        
        let (data, _) = try await session.data(for: urlRequest)
        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .lowerCaseFirstCharacter
        let decoded = try decoder.decode(Eetmeter.Favorites.self, from: data)
        
        await MainActor.run { self.favorites = decoded.items }
    }
    
    func fetchCombinedProducts() async throws -> [Eetmeter.CombinedProduct] {
        guard let url = URL(string: API_URL + "combinedproduct") else { fatalError("Missing URL") }
        let urlRequest = getUrlRequest(url: url, auth: true)
        
        let (data, _) = try await session.data(for: urlRequest)
        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .lowerCaseFirstCharacter
        let decoded = try decoder.decode(Eetmeter.CombinedProducts.self, from: data)
        return decoded.items
    }
    
    func searchConsumptions(query: String) async throws -> [Eetmeter.ConsumptionSearchResult] {
        guard var url = URL(string: API_URL + "search/31") else { fatalError("Missing URL") }
        url.append(queryItems: [URLQueryItem(name: "query", value: query)])
        let urlRequest = getUrlRequest(url: url, auth: true)
        
        let (data, _) = try await session.data(for: urlRequest)
        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .lowerCaseFirstCharacter
        return try decoder.decode([Eetmeter.ConsumptionSearchResult].self, from: data)
    }
    
    func getByBarcode(barcode: String) async throws -> Eetmeter.BrandProduct {
        let cached = self.cache.getProduct(ean: barcode)
        if (cached != nil) { return cached! }
        
        guard let url = URL(string: API_URL + "brandproduct/ean/" + barcode) else { fatalError("Missing URL") }
        let urlRequest = getUrlRequest(url: url, auth: true)
        
        let (data, _) = try await session.data(for: urlRequest)
        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .lowerCaseFirstCharacter
        let result = try decoder.decode(Eetmeter.BrandProduct.self, from: data)
        self.cache.setProduct(product: result)
        return result
    }
    
    func getBrandProduct(id: UUID) async throws -> Eetmeter.BrandProduct {
        let cached: Eetmeter.BrandProduct? = self.cache.getProduct(id: id)
        if (cached != nil) { return cached! }
        
        guard let url = URL(string: API_URL + "brandproduct/" + id.uuidString) else { fatalError("Missing URL") }
        let urlRequest = getUrlRequest(url: url, auth: true)
        
        let (data, _) = try await session.data(for: urlRequest)
        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .lowerCaseFirstCharacter
        let result = try decoder.decode(Eetmeter.BrandProduct.self, from: data)
        self.cache.setProduct(product: result)
        return result
    }
    
    func getProduct(id: UUID, isUnit: Bool = false) async throws -> Eetmeter.Product {
        let cached: Eetmeter.Product? = isUnit ? self.cache.getProductByUnit(id: id) : self.cache.getProduct(id: id)
        if (cached != nil) { return cached! }
        
        guard let url = URL(string: API_URL + "product/" + (isUnit ? "unit/" : "") + id.uuidString) else { fatalError("Missing URL") }
        let urlRequest = getUrlRequest(url: url, auth: true)
        
        let (data, _) = try await session.data(for: urlRequest)
        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .lowerCaseFirstCharacter
        let result = try decoder.decode(Eetmeter.Product.self, from: data)
        self.cache.setProduct(product: result)
        return result
    }
    
    func getBaseProduct(id: UUID, isUnit: Bool = false) async throws -> Eetmeter.BaseProduct {
        let cached: Eetmeter.BaseProduct? = isUnit ? self.cache.getProductByUnit(id: id) : self.cache.getProduct(id: id)
        if (cached != nil) { return cached! }
        
        guard let url = URL(string: API_URL + "baseproduct/" + (isUnit ? "unit/" : "") + id.uuidString) else { fatalError("Missing URL") }
        let urlRequest = getUrlRequest(url: url, auth: true)
        
        let (data, _) = try await session.data(for: urlRequest)
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
        guard let url = URL(string: API_URL + "consumptiondaynote") else { fatalError("Missing URL") }
        var urlRequest = getUrlRequest(url: url, auth: true)
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
        
        let _ = try await session.data(for: urlRequest)
    }
    
    func saveProduct(update: Eetmeter.ProductUpdate) async throws {
        guard let url = URL(string: API_URL + "consumption") else { fatalError("Missing URL") }
        var urlRequest = getUrlRequest(url: url, auth: true)
        urlRequest.httpMethod = "PUT"
        urlRequest.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .eetmeterDate
        urlRequest.httpBody = try encoder.encode(update)
        
        let _ = try await session.data(for: urlRequest)
    }
    
    func saveCombinedProduct(id: UUID, update: Eetmeter.CombinedProductUpdate) async throws {
        guard let url = URL(string: API_URL + "combinedproduct/" + id.uuidString + "/addtodiary") else { fatalError("Missing URL") }
        var urlRequest = getUrlRequest(url: url, auth: true)
        urlRequest.httpMethod = "POST"
        urlRequest.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .eetmeterDate
        urlRequest.httpBody = try encoder.encode(update)
        
        let _ = try await session.data(for: urlRequest)
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
        guard let url = URL(string: API_URL + "consumption/" + id.uuidString) else { fatalError("Missing URL") }
        var urlRequest = getUrlRequest(url: url, auth: true)
        urlRequest.httpMethod = "DELETE"
        let _ = try await session.data(for: urlRequest)
    }
    
    func login(email: String, password: String) async throws {
        guard let url = URL(string: API_URL + "account/credentials") else { fatalError("Missing URL") }
        var urlRequest = getUrlRequest(url: url, auth: false)
        urlRequest.httpMethod = "POST"
        urlRequest.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let encoder = JSONEncoder()
        urlRequest.httpBody = try encoder.encode(Eetmeter.Login(deviceId: self.deviceId, emailAddress: email, password: password))
        
        let (data, _) = try await session.data(for: urlRequest)
        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .lowerCaseFirstCharacter
        let decoded = try decoder.decode(Eetmeter.Account.self, from: data)
        
        await MainActor.run {
            self.authToken = decoded.token
            self.loggedIn = true
            UserDefaults.standard.set(authToken, forKey: "eetmeterAPI.authToken")
        }
        
        try await fetchFavorites()
    }
    
    func logout() {
        self.loggedIn = false
        self.authToken = nil
        self.favorites = []
    }
    
    func getUrlRequest(url: URL, auth: Bool) -> URLRequest {
        var request = URLRequest(url: url)
        
        if (auth) {
            request.setValue("Basic " + ((authToken ?? "") + ":" + self.deviceId), forHTTPHeaderField: "authorization")
        }
        request.setValue("4.6.0", forHTTPHeaderField: "version")
        request.setValue("iOS", forHTTPHeaderField: "platform")
        
        return request
    }
}
