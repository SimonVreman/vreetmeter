
import Foundation

struct NumericalDatePoint: Comparable {
    let date: Date
    let value: Double
    
    static func < (lhs: NumericalDatePoint, rhs: NumericalDatePoint) -> Bool {
        return lhs.value < rhs.value
    }
}

extension [NumericalDatePoint] {
    func average() -> Double? {
        return self.isEmpty ? nil : self.reduce(0) { $0 + $1.value } / Double(self.count)
    }
}
