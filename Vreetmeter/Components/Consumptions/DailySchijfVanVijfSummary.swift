
import SwiftUI

private struct ColumnProgress: View {
    var column: SchijfVanVijfColumn
    var progress: Double
    
    var body: some View {
        NutritionalTargetProgress(
            label: column.getLabel(),
            target: column.getTarget(),
            unit: NutritionUnit.gram,
            progress: progress
        )
    }
}

struct DailySchijfVanVijfSummary: View {
    var consumptions: [Consumption]
    
    @State private var showSheet: Bool = false
    
    private var percentage: Double? {
        consumptions.percentageSchijfVanVijf
    }

    private var color: Color? {
        if percentage == nil {
            return nil
        } else if percentage! >= 85 {
            return .green
        } else if percentage! >= 40 {
            return .yellow
        }
        return .red
    }
    
    private func columnProgress(_ column: SchijfVanVijfColumn) -> Double {
        return consumptions.reduce(0) {
            if ($1.schijfVanVijfColumn == column) {
                return $0 + ($1.grams ?? 0)
            } else {
                return $0
            }
        }
    }
    
    var body: some View {
        HStack {
            SchijfVanVijfIcon(highlighted: consumptions.schijfVanVijfCategories, empty: consumptions.isEmpty)
                .frame(width: 65)
            
            Spacer()
            
            if color == nil {
                PercentageGauge(percentage: percentage)
            } else {
                PercentageGauge(percentage: percentage).tint(color!)
            }
        }.onTapGesture { showSheet.toggle() }
            .sheet(isPresented: $showSheet) {
            NavigationView {
                ScrollView {
                    VStack {
                        GroupBox {
                            ColumnProgress(column: .vegetables, progress: self.columnProgress(.vegetables))
                            Divider()
                            ColumnProgress(column: .fruits, progress: self.columnProgress(.fruits))
                        }.cardBackgroundAndShadow()
                        GroupBox {
                            ColumnProgress(column: .fats, progress: self.columnProgress(.fats))
                        }.cardBackgroundAndShadow()
                        GroupBox {
                            ColumnProgress(column: .fishAndMeat, progress: self.columnProgress(.fishAndMeat))
                            Divider()
                            ColumnProgress(column: .nuts, progress: self.columnProgress(.nuts))
                            Divider()
                            ColumnProgress(column: .dairy, progress: self.columnProgress(.dairy))
                            Divider()
                            ColumnProgress(column: .cheese, progress: self.columnProgress(.cheese))
                        }.cardBackgroundAndShadow()
                        GroupBox {
                            ColumnProgress(column: .bread, progress: self.columnProgress(.bread))
                            Divider()
                            ColumnProgress(column: .grainAndPotatos, progress: self.columnProgress(.grainAndPotatos))
                        }.cardBackgroundAndShadow()
                        GroupBox {
                            ColumnProgress(column: .drinks, progress: self.columnProgress(.drinks))
                        }.cardBackgroundAndShadow()
                    }.padding()
                }.navigationTitle("Schijf van Vijf")
            }.presentationBackground(.ultraThinMaterial)
        }
    }
}

#Preview {
    VStack {
        let guess = GuessConsumption(id: UUID(), energy: 500, carbohydrates: 10, protein: 40, fat: 30)
        let svv = GenericConsumption(consumption: Eetmeter.Consumption(id: UUID(), active: true, amount: 100, brandName: "", consumptionDate: Date.now, createdDate: Date.now, eiwit: 100, eiwitPlantaardig: 20, energie: 400, fosfor: 0, isCombinedProduct: false, isDaily: false, koolhydraten: 1, natrium: 0, period: 1, preparationMethodName: "", productName: "", productType: 0, productUnitId: UUID(), suikers: 0, svvCategory: "A", svvColumn: 1, unitName: "", updatedDate: Date.now, verzadigdVet: 0, vet: 0, vezels: 0, webAccountId: UUID(), zout: 0), grams: 100, date: Date.now)
        DailySchijfVanVijfSummary(consumptions: [])
        DailySchijfVanVijfSummary(consumptions: [guess])
        DailySchijfVanVijfSummary(consumptions: [guess, svv])
        DailySchijfVanVijfSummary(consumptions: [svv])
    }
}
