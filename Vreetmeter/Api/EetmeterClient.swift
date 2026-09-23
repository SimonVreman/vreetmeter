
import SwiftUI
import Security

enum EetmeterError: Error {
    case invalidResponse
    case authenticationError
    case unitNotFound(UUID)
}

class EetmeterClient {
    private let api = "https://api3-mijn.voedingscentrum.nl/api/"
    private let session: URLSession = URLSession.shared
    private var token: String?
    var loggedIn: Bool { self.token != nil }
    
    private let tokenKey = "eetmeter.client.token"
    
    init() {
        // Migrate tokens stored by older versions from UserDefaults to the keychain
        if let legacyToken = UserDefaults.standard.string(forKey: tokenKey) {
            Keychain.set(legacyToken, forKey: tokenKey)
            UserDefaults.standard.removeObject(forKey: tokenKey)
        }
        self.token = Keychain.get(forKey: tokenKey)
    }
    
    func login(token: String) {
        self.token = token
        Keychain.set(token, forKey: tokenKey)
    }
    
    func logout() {
        self.token = nil
        Keychain.delete(forKey: tokenKey)
    }
    
    func makeRequest(_ url: String, query: [URLQueryItem] = []) -> URLRequest {
        var url = URL(string: self.api + url)!
        if (!query.isEmpty) { url.append(queryItems: query) }
        
        // EetmeterCache does the caching, the URL cache would only serve stale days
        var request = URLRequest(url: url, cachePolicy: .reloadIgnoringLocalCacheData)
        
        if (self.token != nil) {
            request.setValue("Basic " + self.token!, forHTTPHeaderField: "authorization")
        }

        request.setValue("4.6.0", forHTTPHeaderField: "version")
        request.setValue("iOS", forHTTPHeaderField: "platform")
        
        return request
    }
    
    func requestData(_ request: URLRequest) async throws -> Data {
        let (data, rawResponse) = try await session.data(for: request)
        let response = rawResponse as? HTTPURLResponse
        
        if response == nil { throw EetmeterError.invalidResponse }
        
        if response!.statusCode == 401 || response!.statusCode == 403 {
            self.logout()
            throw EetmeterError.authenticationError
        }
        
        return data
    }
}

private enum Keychain {
    private static func query(forKey key: String) -> [String: Any] {
        [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: Bundle.main.bundleIdentifier ?? "Vreetmeter",
            kSecAttrAccount as String: key,
        ]
    }
    
    static func get(forKey key: String) -> String? {
        var query = query(forKey: key)
        query[kSecReturnData as String] = true
        query[kSecMatchLimit as String] = kSecMatchLimitOne
        
        var result: AnyObject?
        guard SecItemCopyMatching(query as CFDictionary, &result) == errSecSuccess,
              let data = result as? Data else { return nil }
        return String(decoding: data, as: UTF8.self)
    }
    
    static func set(_ value: String, forKey key: String) {
        delete(forKey: key)
        var query = query(forKey: key)
        query[kSecValueData as String] = Data(value.utf8)
        query[kSecAttrAccessible as String] = kSecAttrAccessibleAfterFirstUnlockThisDeviceOnly
        SecItemAdd(query as CFDictionary, nil)
    }
    
    static func delete(forKey key: String) {
        SecItemDelete(query(forKey: key) as CFDictionary)
    }
}
