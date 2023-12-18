
import SwiftUI

struct DailySchijfVanVijfSummary: View {
    var consumptions: [Consumption]
    
    @State private var showSheet: Bool = false
    
    private var percentage: Double? {
        consumptions.percentageSchijfVanVijf
    }

    private var warning: AnyView {
        if percentage == nil {
            return AnyView(EmptyView())
        } else if percentage! >= 85 {
            return AnyView(Image(systemName: "checkmark.circle.fill").foregroundStyle(.white, .green))
        } else if percentage! >= 40 {
            return AnyView(Image(systemName: "exclamationmark.triangle.fill").foregroundStyle(.black, .yellow))
        }
        return AnyView(Image(systemName: "exclamationmark.triangle.fill").foregroundStyle(.white, .red))
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
                .frame(width: 75)
            
            Spacer()
            
            warning.font(.title)
            
            Text(percentage != nil ? "\(Int(percentage!.rounded()))" : "--")
                .font(.system(.title, design: .rounded, weight: .semibold)) +
            Text("%").font(.system(.title, design: .rounded, weight: .semibold)).foregroundStyle(.secondary)
        }.onTapGesture { showSheet.toggle() }
            .sheet(isPresented: $showSheet) {
            NavigationView {
                ScrollView {
                    VStack {
                        ForEach(SchijfVanVijfColumn.allCases, id: \.self) { column in
                            GroupBox {
                                NutritionalTargetProgress(
                                    label: column.getLabel(),
                                    target: column.getTarget(),
                                    unit: NutritionUnit.gram,
                                    progress: self.columnProgress(column)
                                )
                            }.cardBackgroundAndShadow()
                        }
                    }.padding()
                }.navigationTitle("Overview")
            }.presentationBackground(.ultraThinMaterial)
        }
    }
}

#Preview {
    VStack {
        DailySchijfVanVijfSummary(consumptions: [GuessConsumption(id: UUID(), energy: 500, carbohydrates: 10, protein: 40, fat: 30)])
        DailySchijfVanVijfSummary(consumptions: [])
    }
}
