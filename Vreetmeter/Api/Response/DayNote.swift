
import Foundation

extension Eetmeter {
    nonisolated struct DayNote: Identifiable, Codable {
        let id: UUID
        var consumptionDate: Date
        var note: String
    }

    nonisolated struct DayMeta: Identifiable, Codable {
        let id: UUID
        var guesses: [Eetmeter.Guess]
    }
    
    nonisolated struct Guess: Identifiable, Codable {
        let id: UUID
        var period: Int
        var energy: Double
        var protein: Double
        var fat: Double
        var carbs: Double
    }

    nonisolated struct GuessUpdate {
        var id: UUID?
        var period: Int
        var date: Date
        var energy: Double
        var protein: Double
        var fat: Double
        var carbs: Double
    }
}
