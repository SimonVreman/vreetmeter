
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
    
    func getAllForRange(start: Date, days: Int) -> [any Consumption] {
        var result: [Consumption] = []
        for i in 0..<Int(days) {
            let day = Calendar.current.date(byAdding: .day, value: i, to: start)!
            result.append(contentsOf: getAllForDay(day))
        }
        return result
    }
    
    func didFetchForDay(_ day: Date) -> Bool {
        return self.daysFetched.contains(day.startOfDay)
    }
    
    func fetchForRange(start: Date, days: Int) async throws {
        for i in 0..<Int(days) {
            let day = Calendar.current.date(byAdding: .day, value: i, to: start)!
            try await self.fetchForDay(day)
        }
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
            filledConsumptions.append(await self.createConsumptionObject(c, day: day))
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
    
    /// Builds a consumption from the API item. The item already carries energy, macros and names, so product
    /// lookups (for grams and micronutrients) are best-effort and never cause a logged item to be dropped.
    private func createConsumptionObject(_ c: Eetmeter.Consumption, day: Date) async -> Consumption {
        var grams: Double?
        do {
            let unit = try await self.api.getUnit(id: c.productUnitId, brandProductId: c.brandProductId)
            grams = c.amount * Double(unit.gramsPerUnit)
        } catch {
            print("Unit lookup failed for \(c.productName) (unit \(c.productUnitId), brand product \(String(describing: c.brandProductId))): \(error)")
        }
        
        if let brandProductId = c.brandProductId {
            var consumption = BrandConsumption(consumption: c, grams: grams, date: day)
            guard let grams else { return consumption }
            do {
                try await self.fillBrandNutritionalValues(&consumption, brandProductId: brandProductId, unitId: c.productUnitId, consumed: grams)
            } catch {
                print("Nutritional lookup failed for \(c.productName) (brand product \(brandProductId)): \(error)")
            }
            return consumption
        }
        
        var consumption = GenericConsumption(consumption: c, grams: grams, date: day)
        guard let grams else { return consumption }
        do {
            let nutritional = try await self.api.getVariant(unitId: c.productUnitId).variant
            consumption.fillOptionalNutrionalValues(p: nutritional, consumed: grams)
        } catch {
            print("Nutritional lookup failed for \(c.productName) (unit \(c.productUnitId)): \(error)")
        }
        return consumption
    }
    
    private func fillBrandNutritionalValues(_ consumption: inout BrandConsumption, brandProductId: UUID, unitId: UUID, consumed: Double) async throws {
        let product = try await self.api.getBrandProduct(id: brandProductId)
        let variant = product.product.preparationVariants.first { v in v.product.units.contains { u in u.id == unitId } }
        
        // For brand consumptions, we have three different data sources
        //   1. The brand nutritional values, if product is raw
        //   2. A fallback to generic nutritional values, if the product is raw
        //   3. The preparation variant values, if product is not raw and we have such a variant
        
        if variant != nil && !variant!.product.preparationMethod.isRaw {
            consumption.fillOptionalNutrionalValues(p: variant!.product, consumed: consumed) // Source 3.
            return
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
    }
}
