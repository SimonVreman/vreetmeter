import Foundation
import Testing
@testable import Vreetmeter

@MainActor
struct DoubleFormatTests {
    @Test(arguments: [
        (1.23, "1.2"),
        (99.9, "99.9"),
        (123.4, "123"),
        (1000, "1.0k"),
        (1234, "1.2k"),
        (12345, "12k"),
    ])
    func formatNutritional(value: Double, expected: String) {
        #expect(value.formatNutritional() == expected)
    }
}

@MainActor
struct DateManipulationTests {
    @Test func startOfDayDropsTime() {
        let date = Calendar.current.date(from: DateComponents(year: 2025, month: 6, day: 15, hour: 13, minute: 37))!
        let start = date.startOfDay
        #expect(Calendar.current.dateComponents([.hour, .minute, .second], from: start) == DateComponents(hour: 0, minute: 0, second: 0))
        #expect(Calendar.current.isDate(start, inSameDayAs: date))
    }
}

@MainActor
struct NumericalDatePointTests {
    @Test func averageOfEmptyIsNil() {
        #expect([NumericalDatePoint]().average() == nil)
    }

    @Test func average() {
        let points = [70.0, 72.0, 74.0].map { NumericalDatePoint(date: .now, value: $0) }
        #expect(points.average() == 72.0)
    }
}

@MainActor
struct JSONHandlingTests {
    struct Sample: Codable, Equatable {
        var productName: String
        var amount: Double
    }

    @Test func decodesUpperCamelCaseKeys() throws {
        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .lowerCaseFirstCharacter
        let json = Data(#"{"ProductName": "Appel", "Amount": 150}"#.utf8)
        #expect(try decoder.decode(Sample.self, from: json) == Sample(productName: "Appel", amount: 150))
    }

    @Test func encodesUpperCamelCaseKeys() throws {
        let encoder = JSONEncoder()
        encoder.keyEncodingStrategy = .upperCaseFirstCharacter
        let object = try JSONSerialization.jsonObject(with: encoder.encode(Sample(productName: "Appel", amount: 150))) as? [String: Any]
        #expect(object?.keys.sorted() == ["Amount", "ProductName"])
    }

    @Test func metaRoundTrip() throws {
        let sample = Sample(productName: "Appel", amount: 150)
        let encoded = "Name" + (try encodeVreetmeterMeta(input: sample))
        let decoded: Sample? = try decodeVreetmeterMeta(input: encoded)
        #expect(decoded == sample)
        #expect(encoded.replacing(META_PATTERN, with: "") == "Name")
    }

    @Test func missingMetaDecodesToNil() throws {
        let decoded: Sample? = try decodeVreetmeterMeta(input: "Plain name")
        #expect(decoded == nil)
    }
}
