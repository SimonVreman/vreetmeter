
import SwiftUI

struct DailySchijfVanVijfSummary: View {
    var consumptions: [Consumption]
    
    private var percentage: Double? {
        consumptions.percentageSchijfVanVijf
    }

    private var warning: AnyView {
        if percentage == nil {
            return AnyView(EmptyView())
        } else if percentage! >= 85 {
            return AnyView(Image(systemName: "checkmark.circle.fill").foregroundStyle(.white, .green))
        } else if percentage! >= 40 {
            return AnyView(Image(systemName: "exclamationmark.triangle.fill").foregroundStyle(.white, .orange))
        }
        return AnyView(Image(systemName: "exclamationmark.triangle.fill").foregroundStyle(.white, .red))
    }
    
    private var categories: Set<SchijfVanVijfCategory> {
        return Set(consumptions.reduce([]) {
            if $1.schijfVanVijfCategory == nil { return $0 }
            return $0 + [$1.schijfVanVijfCategory!]
        })
    }
    
    var body: some View {
        HStack {
            SchijfVanVijfIcon(highlighted: categories)
                .frame(width: 75)
                .if(consumptions.isEmpty, transform: { $0.grayscale(1) })
            
            Spacer()
            
            warning.font(.title)
            
            Text(percentage != nil ? "\(Int(percentage!.rounded()))" : "--")
                .font(.system(.title, design: .rounded, weight: .semibold)) +
            Text("%").font(.system(.title, design: .rounded, weight: .semibold)).foregroundStyle(.secondary)
        }
    }
}

#Preview {
    VStack {
        DailySchijfVanVijfSummary(consumptions: [GuessConsumption(id: UUID(), energy: 500, carbohydrates: 10, protein: 40, fat: 30)])
        DailySchijfVanVijfSummary(consumptions: [])
    }
}
