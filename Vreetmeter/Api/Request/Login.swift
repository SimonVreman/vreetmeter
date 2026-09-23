
import Foundation

extension Eetmeter {
    nonisolated struct Login: Codable {
        var deviceId: String
        var emailAddress: String
        var password: String
    }
}
