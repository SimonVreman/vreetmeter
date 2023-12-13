
import Foundation

protocol Consumption: AnyObject, Nutritional, SchijfVanVijf {
    var id: UUID { get }
    var date: Date? { get }
    var meal: Meal? { get }
}

extension [Consumption] {
    var percentageSchijfVanVijf: Double? {
        let totalCalories = self.reduce(0) { $0 + $1.energy }
        if totalCalories == 0 { return nil }
        let schijfVanVijfCalories = self.reduce(0) { $1.isSchijfVanVijf ? $0 + $1.energy : $0 }
        return schijfVanVijfCalories / totalCalories * 100
    }
    
    var schijfVanVijfCategories: Set<SchijfVanVijfCategory> {
        return Set(self.reduce([]) {
            if $1.schijfVanVijfCategory == nil { return $0 }
            return $0 + [$1.schijfVanVijfCategory!]
        })
    }
}
