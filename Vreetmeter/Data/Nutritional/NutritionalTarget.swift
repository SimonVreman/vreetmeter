
import Foundation

/**
 These definitions are based on data from Voedingcentrum for me specifically, could use some configuration lol.
 */

struct NutritionalTarget {
    let dangerMin: Double?
    let min: Double?
    let max: Double?
    let dangerMax: Double?
    let per1000kcal: Bool
    
    init(dangerMin: Double?, min: Double?, max: Double?, dangerMax: Double?, per1000kcal: Bool = false) {
        self.dangerMin = dangerMin
        self.min = min
        self.max = max
        self.dangerMax = dangerMax
        self.per1000kcal = per1000kcal
    }
}
