
import SwiftUI
import HealthKit

@Observable class HealthState {
    private let foodObjectTypes = [
        HKQuantityType(.dietaryEnergyConsumed),
        HKQuantityType(.dietaryCarbohydrates),
        HKQuantityType(.dietaryProtein),
        HKQuantityType(.dietaryFatTotal),
        
        // Optional nutritional values
        // Macronutrients
        HKQuantityType(.dietaryFiber),
        HKQuantityType(.dietarySugar),
        HKQuantityType(.dietaryFatMonounsaturated),
        HKQuantityType(.dietaryFatPolyunsaturated),
        HKQuantityType(.dietaryFatSaturated),
        HKQuantityType(.dietaryCholesterol),

        // Vitamins
        HKQuantityType(.dietaryVitaminA),
        HKQuantityType(.dietaryThiamin),
        HKQuantityType(.dietaryRiboflavin),
        HKQuantityType(.dietaryNiacin),
        HKQuantityType(.dietaryPantothenicAcid),
        HKQuantityType(.dietaryVitaminB6),
        HKQuantityType(.dietaryBiotin),
        HKQuantityType(.dietaryVitaminB12),
        HKQuantityType(.dietaryVitaminC),
        HKQuantityType(.dietaryVitaminD),
        HKQuantityType(.dietaryVitaminE),
        HKQuantityType(.dietaryVitaminK),
        HKQuantityType(.dietaryFolate),
        
        // Minerals
        HKQuantityType(.dietaryCalcium),
        HKQuantityType(.dietaryChloride),
        HKQuantityType(.dietaryIron),
        HKQuantityType(.dietaryMagnesium),
        HKQuantityType(.dietaryPhosphorus),
        HKQuantityType(.dietaryPotassium),
        HKQuantityType(.dietarySodium),
        HKQuantityType(.dietaryZinc),

        // Ultratrace Minerals
        HKQuantityType(.dietaryChromium),
        HKQuantityType(.dietaryCopper),
        HKQuantityType(.dietaryIodine),
        HKQuantityType(.dietaryManganese),
        HKQuantityType(.dietaryMolybdenum),
        HKQuantityType(.dietarySelenium),
    ]
    
    private let bodyObjectTypes = [HKQuantityType(.bodyMass)]
    private let correlationEnergyKey = "vreetmeter.energy"
    
    private let store: HKHealthStore?
    
    var authorizationStatus: HKAuthorizationStatus? {
        return self.store?.authorizationStatus(for: HKCorrelationType(.food))
    }
    
    var isAvailable: Bool {
        return self.store != nil
    }
    
    init() {
        self.store = HKHealthStore.isHealthDataAvailable() ? HKHealthStore() : nil
    }
    
    func requestPermission() async throws {
        try await self.store?.requestAuthorization(
            toShare: Set(self.foodObjectTypes),
            read: Set(self.foodObjectTypes + self.bodyObjectTypes)
        )
    }
    
    public func queryRecentBodyMass(date: Date) async throws -> Double? {
        if !self.isAvailable { return nil }
        
        let start = Calendar.current.date(byAdding: .day, value: -7 * 4, to: date)!
        let results = try await self.queryBodyMass(start: start, end: date, interval: DateComponents(day: 7))
        let sample = results?.last
        
        return sample?.averageQuantity()?.doubleValue(for: .gramUnit(with: .kilo))
    }
    
    public func queryBodyMass(start: Date, end: Date, interval: DateComponents) async throws -> [HKStatistics]? {
        if !self.isAvailable { return nil }
        
        let quantityType = HKQuantityType(.bodyMass)
        let predicateRange = HKQuery.predicateForSamples(withStart: start, end: end)
        let samplePredicate = HKSamplePredicate.quantitySample(type: quantityType, predicate: predicateRange)

        let descriptor = HKStatisticsCollectionQueryDescriptor(
            predicate: samplePredicate,
            options: .discreteAverage,
            anchorDate: start,
            intervalComponents: interval
        )
        
        let results = try await descriptor.result(for: self.store!)
        return results.statistics()
    }
    
    public func synchronizeConsumptions(day: Date, consumptions: [Consumption]) async throws {
        if !self.isAvailable { return } //todo: permission checking?
        
        let startDate = day.startOfDay
        let endDate = Calendar.current.date(byAdding: DateComponents(day: 1), to: startDate)
        let predicateRange = HKQuery.predicateForSamples(withStart: startDate, end: endDate, options: .strictStartDate)
        let predicate = HKSamplePredicate.correlation(type: HKCorrelationType(.food), predicate: predicateRange)
        let descriptor = HKSampleQueryDescriptor(predicates: [predicate], sortDescriptors: [SortDescriptor(\.endDate)])
        
        let allResults = try await descriptor.result(for: self.store!)
        let persistedCorrelations = allResults.filter { $0.sourceRevision.source == HKSource.default() }
        
        let objectsToDelete = persistedCorrelations.filter { correlation in
            return !consumptions.contains { consumption in
                self.isCorrelationForConsumption(correlation: correlation, consumption: consumption)
            }
        }.flatMap { correlation in [correlation] + correlation.objects }
        
        let correlationsToStore = consumptions.filter { consumption in
            return !persistedCorrelations.contains { correlation in
                self.isCorrelationForConsumption(correlation: correlation, consumption: consumption)
            }
        }.map { c in createCorrelation(c: c, day: day) }
        
        if !objectsToDelete.isEmpty { try await self.store!.delete(objectsToDelete) }
        if !correlationsToStore.isEmpty { try await self.store!.save(correlationsToStore) }
    }
    
    private func isCorrelationForConsumption(correlation: HKCorrelation, consumption: Consumption) -> Bool {
        // Compare by UUID
        let correlationId = correlation.metadata?[HKMetadataKeyExternalUUID] as? String
        let consumptionIdString = consumption.id.uuidString
        if correlationId != consumptionIdString { return false }
        
        // Compare by energy
        let correlationEnergy = correlation.metadata?[self.correlationEnergyKey] as? Double
        let consumptionEnergy = consumption.energy
        return correlationEnergy?.rounded() == consumptionEnergy.rounded()
    }

    private func createCorrelation(c: Consumption, day: Date) -> HKCorrelation {
        let meal = c.meal ?? Meal.snack
        let time = meal.getTimeOfDay(day: c.date ?? day)
        
        var samples = self.createCorrelationSamples(c: c, start: time.start, end: time.end)
        samples.insert(HKQuantitySample(
            type: .init(.dietaryEnergyConsumed),
            quantity: HKQuantity(unit: .largeCalorie(), doubleValue: c.energy),
            start: time.start,
            end: time.end
        ))
        
        let name = (c as? GenericConsumption)?.productName ?? (c as? BrandConsumption)?.productName ?? "Guess"
        
        let meta: [String:Any] = [
            HKMetadataKeyExternalUUID: c.id.uuidString,
            HKMetadataKeyFoodType: name,
            correlationEnergyKey: c.energy
        ]
        
        return HKCorrelation(type: .init(.food), start: time.start, end: time.end, objects: samples, metadata: meta)
    }
    
    private func createCorrelationSamples(c: Consumption, start: Date, end: Date) -> Set<HKSample> {
        var set: Set<HKSample> = []
        
        let insertSample = { (type: HKQuantityTypeIdentifier, amount: Double?) -> Void in
            if amount == nil { return }
            let sample = HKQuantitySample(type: .init(type), quantity: HKQuantity(unit: .gram(), doubleValue: amount!), start: start, end: end)
            set.insert(sample)
        }
        
        insertSample(.dietaryCarbohydrates, c.carbohydrates)
        insertSample(.dietaryProtein, c.protein)
        insertSample(.dietaryFatTotal, c.fat)
        
        // Optional nutritional values
        // Macronutrients
        insertSample(.dietaryFiber, c.fiber)
        insertSample(.dietarySugar, c.sugar)
        insertSample(.dietaryFatMonounsaturated, c.fatMonounsaturated)
        insertSample(.dietaryFatPolyunsaturated, c.fatPolyunsaturated)
        insertSample(.dietaryFatSaturated, c.fatSaturated)
        insertSample(.dietaryCholesterol, c.cholesterol)

        // Vitamins
        insertSample(.dietaryVitaminA, c.vitaminA)
        insertSample(.dietaryThiamin, c.thiamin)
        insertSample(.dietaryRiboflavin, c.riboflavin)
        insertSample(.dietaryNiacin, c.niacin)
        insertSample(.dietaryPantothenicAcid, c.pantothenicAcid)
        insertSample(.dietaryVitaminB6, c.vitaminB6)
        insertSample(.dietaryBiotin, c.biotin)
        insertSample(.dietaryVitaminB12, c.vitaminB12)
        insertSample(.dietaryVitaminC, c.vitaminC)
        insertSample(.dietaryVitaminD, c.vitaminD)
        insertSample(.dietaryVitaminE, c.vitaminE)
        insertSample(.dietaryVitaminK, c.vitaminK)
        insertSample(.dietaryFolate, c.folate)
        
        // Minerals
        insertSample(.dietaryCalcium, c.calcium)
        insertSample(.dietaryChloride, c.chloride)
        insertSample(.dietaryIron, c.iron)
        insertSample(.dietaryMagnesium, c.magnesium)
        insertSample(.dietaryPhosphorus, c.phosphorus)
        insertSample(.dietaryPotassium, c.potassium)
        insertSample(.dietarySodium, c.sodium)
        insertSample(.dietaryZinc, c.zinc)

        // Ultratrace Minerals
        insertSample(.dietaryChromium, c.chromium)
        insertSample(.dietaryCopper, c.copper)
        insertSample(.dietaryIodine, c.iodine)
        insertSample(.dietaryManganese, c.manganese)
        insertSample(.dietaryMolybdenum, c.molybdenum)
        insertSample(.dietarySelenium, c.selenium)
        
        return set
    }
}
