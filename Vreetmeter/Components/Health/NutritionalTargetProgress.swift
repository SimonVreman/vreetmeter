
import SwiftUI
import Charts

struct NutritionalTargetProgress: View {
    var column: SchijfVanVijfColumn
    var consumptions: [Consumption]
    
    private var progress: Double {
        consumptions.reduce(0) {
            if ($1.schijfVanVijfColumn == column) {
                return $0 + ($1.grams ?? 0)
            } else {
                return $0
            }
        }
    }
    
    private var target: (min: Double, max: Double) {
        NutritionalTargets().columnTargets[column]!
    }
    
    private var xMax: Double {
        max(Double(target.max), progress) * 1.2
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack {
                Text(column.getLabel())
                    .font(.headline)
                if progress > target.max {
                    Image(systemName: "exclamationmark.triangle.fill")
                        .foregroundStyle(.black, .yellow)
                }
            }
            
            Chart {
                BarMark(x: .value("Progress", progress))
                    .foregroundStyle(.blue)
                
                if target.max > target.min {
                    RectangleMark(xStart: .value("", target.min), xEnd: .value("", target.max))
                        .foregroundStyle(.background.secondary.opacity(0.8))
                        .annotation(position: .overlay) {
                            Text("Goal").font(.caption)
                        }
                }
            }.chartXAxis {
                AxisMarks(
                    values: [0, target.min] + (target.max > target.min ? [target.max] : [])
                ) { value in
                    AxisValueLabel {
                        let number = value.as(Double.self) ?? 0
                        Text("\(number, specifier: "%.0f")g")
                    }
                    AxisGridLine()
                }
            }
                .chartXScale(domain: [0, xMax])
                .chartLegend(.hidden)
                .frame(height: 40)
        }
    }
}

#Preview {
    VStack {
        var consumption = Eetmeter.Consumption(id: UUID(), active: true, amount: 1, brandName: "", consumptionDate: Date.now, createdDate: Date.now, eiwit: 0, eiwitPlantaardig: 0, energie: 0, fosfor: 0, isCombinedProduct: false, isDaily: false, koolhydraten: 0, natrium: 0, period: 0, preparationMethodName: "", productName: "", productType: 0, productUnitId: UUID(), suikers: 0, svvCategory: "", svvColumn: SchijfVanVijfColumn.dairy.rawValue, unitName: "", updatedDate: Date.now, verzadigdVet: 0, vet: 0, vezels: 0, webAccountId: UUID(), zout: 0)
        
        NutritionalTargetProgress(column: .dairy, consumptions: [])
        NutritionalTargetProgress(column: .dairy, consumptions: [
            GenericConsumption(consumption: consumption, grams: 126, date: Date.now)
        ])
        NutritionalTargetProgress(column: .dairy, consumptions: [
            GenericConsumption(consumption: consumption, grams: 371, date: Date.now)
        ])
        NutritionalTargetProgress(column: .dairy, consumptions: [
            GenericConsumption(consumption: consumption, grams: 621, date: Date.now)
        ])
        
        let _ = consumption.svvColumn = SchijfVanVijfColumn.nuts.rawValue
        NutritionalTargetProgress(column: .nuts, consumptions: [
            GenericConsumption(consumption: consumption, grams: 50, date: Date.now)
        ])
        
        let _ = consumption.svvColumn = SchijfVanVijfColumn.grainAndPotatos.rawValue
        NutritionalTargetProgress(column: .grainAndPotatos, consumptions: [
            GenericConsumption(consumption: consumption, grams: 220, date: Date.now)
        ])
    }
}
