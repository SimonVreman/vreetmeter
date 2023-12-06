
import SwiftUI

enum EetmeterError: Error {
    case invalidResponse
    case authenticationError
}

class EetmeterClient {
    private let api = "https://api3-mijn.voedingscentrum.nl/api/"
    private let session: URLSession = URLSession.shared
    private var token: String?
    var loggedIn: Bool { self.token != nil }
    
    init() {
        self.token = UserDefaults.standard.object(forKey: "eetmeter.client.token") as? String
    }
    
    func login(token: String) {
        self.token = token
        UserDefaults.standard.set(token, forKey: "eetmeter.client.token")
    }
    
    func logout() {
        self.token = nil
    }
    
    func makeRequest(_ url: String, query: [URLQueryItem] = []) -> URLRequest {
        var url = URL(string: self.api + url)!
        if (!query.isEmpty) { url.append(queryItems: query) }
        
        var request = URLRequest(url: url)
        
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
