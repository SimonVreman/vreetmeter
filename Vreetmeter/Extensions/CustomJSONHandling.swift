
import Foundation

struct AnyKey: CodingKey {
    static let empty = AnyKey(string: "")
    var stringValue: String
    var intValue: Int?

    init?(stringValue: String) {
        self.stringValue = stringValue
        self.intValue = nil
    }

    init?(intValue: Int) {
        self.stringValue = String(intValue)
        self.intValue = intValue
     }

    init(string: String) {
        self.stringValue = string
        self.intValue = nil
    }

  }

public extension JSONDecoder.KeyDecodingStrategy {
    static let lowerCaseFirstCharacter = JSONDecoder.KeyDecodingStrategy.custom({ keys in
        // Should never receive an empty `keys` array in theory.
        guard let lastKey = keys.last?.stringValue else {
            return AnyKey.empty
        }
        return AnyKey(string: lastKey.prefix(1).lowercased() + lastKey.dropFirst())
    })
}

public extension JSONDecoder.DateDecodingStrategy {
    static let eetmeterDate = JSONDecoder.DateDecodingStrategy.formatted({
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSS"
        return dateFormatter
    }())
}

public extension JSONEncoder.KeyEncodingStrategy {
    static let upperCaseFirstCharacter = JSONEncoder.KeyEncodingStrategy.custom({ keys in
        // Should never receive an empty `keys` array in theory.
        guard let lastKey = keys.last?.stringValue else {
            return AnyKey.empty
        }
        return AnyKey(string: lastKey.prefix(1).uppercased() + lastKey.dropFirst())
    })
}

public extension JSONEncoder.DateEncodingStrategy {
    static let eetmeterDate = JSONEncoder.DateEncodingStrategy.formatted({
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSS"
        return dateFormatter
    }())
}

public extension JSONEncoder.DateEncodingStrategy {
    static let eetmeterMidnightDate = JSONEncoder.DateEncodingStrategy.formatted({
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd'T'00:00:00.000"
        return dateFormatter
    }())
}
