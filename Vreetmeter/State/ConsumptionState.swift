
import SwiftUI

@Observable class ConsumptionState {
    private let api: EetmeterAPI
    private var consumptions: [any Consumption] = []
    private var daysFetched: Set<Date> = []
    var day: Date = Date().startOfDay
    
    var dayConsumptions: [any Consumption] {
        return self.consumptions.filter { c in c.date?.startOfDay == day.startOfDay }
    }
    
    var currentDayFetched: Bool {
        return self.daysFetched.contains(self.day.startOfDay)
    }
    
    init(api: EetmeterAPI) {
        self.api = api
    }
    
    func fetchDayConsumptions() async throws {
        let day = self.day.startOfDay
        
        // Fetch required data from the API
        // TODO: make it work in parallel
        let dayConsumptions = try await self.api.fetchDayConsumptions(date: day)
        let dayMeta = try await self.api.fetchDayMeta(date: day)
        
        // Transform to proper types
        var filledConsumptions: [Consumption] = []
        for c in dayConsumptions.items {
            let isBrand = c.brandProductId != nil
            let unit = try await self.api.getUnit(id: c.productUnitId)
            let consumed = c.amount * Double(unit.gramsPerUnit)
            
            var consumption: Consumption
            var nutritional: EetmeterNutritional
            if (isBrand) {
                consumption = BrandConsumption(consumption: c, date: day)
                let product = try await self.api.getBrandProduct(id: c.brandProductId!)
                let variant = product.product.preparationVariants.first { v in v.product.units.contains { u in u.id == c.productUnitId } }
                nutritional = variant == nil || variant!.product.preparationMethod.isRaw ? product : variant!.product
            } else {
                consumption = GenericConsumption(consumption: c, date: day)
                let product = try await self.api.getProduct(id: c.productUnitId, isUnit: true)
                nutritional = product.preparationVariants.first { v in v.product.units.contains { u in u.id == c.productUnitId } }!.product
            }
            
            consumption.fillOptionalNutrionalValues(p: nutritional, consumed: consumed)
            filledConsumptions.append(consumption)
        }
        
        let regularConsumptions = filledConsumptions
        let guessConsumptions = dayMeta.guesses.map { g in
            return GuessConsumption(guess: g, date: day)
        }
        
        DispatchQueue.main.async {
            // Filter old consumptions
            self.consumptions = self.consumptions.filter { c in
                c.date?.startOfDay != day
            }
            
            // Append new consumptions to list
            self.consumptions.append(contentsOf: regularConsumptions)
            self.consumptions.append(contentsOf: guessConsumptions)
            self.daysFetched.insert(day)
        }
    }
}
