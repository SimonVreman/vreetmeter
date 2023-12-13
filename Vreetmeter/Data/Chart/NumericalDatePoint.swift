
import Foundation

struct NumericalDatePoint {
    let date: Date
    let value: Double
}

extension [NumericalDatePoint] {
    func average() -> Double? {
        return self.isEmpty ? nil : self.reduce(0) { $0 + $1.value } / Double(self.count)
    }
}
