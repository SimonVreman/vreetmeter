
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
            let consumption = try? await self.createConsumptionObject(c, day: day)
            if consumption != nil { filledConsumptions.append(consumption!) }
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
    
    private func createConsumptionObject(_ c: Eetmeter.Consumption, day: Date) async throws -> Consumption? {
        let isBrand = c.brandProductId != nil
        let unit = try await self.api.getUnit(id: c.productUnitId)
        let consumed = c.amount * Double(unit.gramsPerUnit)
        
        if (isBrand) {
            var consumption = BrandConsumption(consumption: c, grams: consumed, date: day)
            let product = try await self.api.getBrandProduct(id: c.brandProductId!)
            let variant = product.product.preparationVariants.first { v in v.product.units.contains { u in u.id == c.productUnitId } }
            
            // For brand consumptions, we have three different data sources
            //   1. The brand nutritional values, if product is raw
            //   2. A fallback to generic nutritional values, if the product is raw
            //   3. The preparation variant values, if product is not raw and we have such a variant
            
            if variant != nil && !variant!.product.preparationMethod.isRaw {
                consumption.fillOptionalNutrionalValues(p: variant!.product, consumed: consumed) // Source 3.
                return consumption
            }
            
            let genericNutritional: EetmeterNutritional?
            if variant != nil {
                genericNutritional = variant!.product
            } else {
                let baseProductId = product.product.baseProductId
                let baseProduct = baseProductId != nil ? try? await self.api.getBaseProduct(id: baseProductId!) : nil
                genericNutritional = baseProduct?.products.first
            }
            
            if genericNutritional != nil { consumption.fillOptionalNutrionalValues(p: genericNutritional!, consumed: consumed) } // Source 2.
            consumption.fillOptionalNutrionalValues(p: product, consumed: consumed) // Source 1.
            
            return consumption
        }
        
        var consumption = GenericConsumption(consumption: c, grams: consumed, date: day)
        let product = try await self.api.getProduct(id: c.productUnitId, isUnit: true)
        let nutritional = product.preparationVariants.first { v in v.product.units.contains { u in u.id == c.productUnitId } }!.product
        consumption.fillOptionalNutrionalValues(p: nutritional, consumed: consumed)
        return consumption
    }
}
