
import Foundation

extension Double {
    func formatNutritional() -> String {
        var format = "%.1f"
        if (self >= 10000) {
            format = "%.0fk"
        } else if (self >= 1000) {
            format = "%.1fk"
        } else if (self >= 100) {
            format = "%.0f"
        }
        
        return String(format: format, self > 1000 ? self / 1000 : self)
    }
}
