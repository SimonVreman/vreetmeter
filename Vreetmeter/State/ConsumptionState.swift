
import SwiftUI

@Observable class ConsumptionState {
    private let api: EetmeterAPI
    private var consumptions: [any Consumption] = []
    private var daysFetched: Set<Date> = []
    
    init(api: EetmeterAPI) {
        self.api = api
    }
    
    func getAllForDay(_ day: Date) -> [any Consumption] {
        return self.consumptions.filter { c in c.date?.startOfDay == day.startOfDay }
    }
    
    func didFetchForDay(_ day: Date) -> Bool {
        return self.daysFetched.contains(day.startOfDay)
    }
    
    func fetchForDay(_ day: Date, tryCache: Bool = true) async throws {
        let day = day.startOfDay
        
        // Fetch required data from the API
        // TODO: make it work in parallel
        let dayConsumptions = try await self.api.fetchDayConsumptions(date: day, tryCache: tryCache)
        let dayMeta = try await self.api.fetchDayMeta(date: day, tryCache: tryCache)
        
        // Transform to proper types
        var filledConsumptions: [Consumption] = []
        for c in dayConsumptions.items {
            let isBrand = c.brandProductId != nil
            let unit = try await self.api.getUnit(id: c.productUnitId)
            let consumed = c.amount * Double(unit.gramsPerUnit)
            
            var consumption: Consumption
            var nutritional: EetmeterNutritional
            if (isBrand) {
                consumption = BrandConsumption(consumption: c, grams: consumed, date: day)
                let product = try await self.api.getBrandProduct(id: c.brandProductId!)
                let variant = product.product.preparationVariants.first { v in v.product.units.contains { u in u.id == c.productUnitId } }
                nutritional = variant == nil || variant!.product.preparationMethod.isRaw ? product : variant!.product
            } else {
                consumption = GenericConsumption(consumption: c, grams: consumed, date: day)
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
        
        await MainActor.run {
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
