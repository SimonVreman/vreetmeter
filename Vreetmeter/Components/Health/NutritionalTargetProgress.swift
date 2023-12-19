
import SwiftUI
import Charts

struct NutritionalTargetProgress: View {
    var label: String
    var target: NutritionalTarget
    var unit: NutritionUnit
    var progress: Double
    
    var domainEnd: Double {
        let maximum = max(progress, target.dangerMax ?? target.max ?? target.min ?? 0)
        return maximum * 1.3
    }
    
    var rangeLabel: String {
        let hasMax = (target.dangerMax ?? target.max) != nil
        let hasMin = (target.dangerMin ?? target.min) != nil
        let maxLabel = "\(Int(target.max ?? target.dangerMax ?? 0))\(unit.rawValue)"
        let minLabel = "\(Int(target.min ?? target.dangerMin ?? 0))\(unit.rawValue)"
        if hasMin && hasMax {
            return "\(minLabel) - \(maxLabel)"
        } else if hasMin {
            return "> \(minLabel)"
        } else if hasMax {
            return "< \(maxLabel)"
        }
        return ""
    }
    
    var zoneIcon: AnyView {
        let dangerMin = target.dangerMin != nil && progress < target.dangerMin!
        let dangerMax = target.dangerMax != nil && progress > target.dangerMax!
        
        if dangerMin || dangerMax {
            return AnyView(Image(systemName: "exclamationmark.triangle.fill")
                .foregroundStyle(.white, .red))
        }
        
        let warningMin = target.min != nil && progress < target.min!
        let warningMax = target.max != nil && progress > target.max!
        
        if warningMin || warningMax {
            return AnyView(Image(systemName: "exclamationmark.triangle.fill")
                .foregroundStyle(.black, .yellow))
        }
        
        return AnyView(Image(systemName: "checkmark.circle.fill")
            .foregroundStyle(.white, .green))
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack {
                zoneIcon
                Text(label).font(.headline)
                Spacer()
                Text(rangeLabel).font(.caption)
                    .foregroundStyle(.secondary)
            }
            
            Chart {
                // Dangerously low
                if target.dangerMin != nil {
                    RectangleMark(
                        xStart: .value("start", 0),
                        xEnd: .value("end", target.dangerMin!)
                    ).foregroundStyle(.red).opacity(0.4)
                }
                
                // Low
                if target.min != nil {
                    RectangleMark(
                        xStart: .value("start", target.dangerMin ?? 0),
                        xEnd: .value("end", target.min!)
                    ).foregroundStyle(.yellow).opacity(0.4)
                }
                
                // Normal
                RectangleMark(
                    xStart: .value("start", target.min ?? target.dangerMin ?? 0),
                    xEnd: .value("end", target.max ?? target.dangerMax ?? domainEnd)
                ).foregroundStyle(.green).opacity(0.4)
                
                // High
                if target.max != nil {
                    RectangleMark(
                        xStart: .value("start", target.max!),
                        xEnd: .value("end", target.dangerMax ?? domainEnd)
                    ).foregroundStyle(.yellow).opacity(0.4)
                }
                
                // Dangerously high
                if target.dangerMax != nil {
                    RectangleMark(
                        xStart: .value("start", target.dangerMax!),
                        xEnd: .value("end", domainEnd)
                    ).foregroundStyle(.red).opacity(0.4)
                }
                
                RuleMark(x: .value("progress", progress))
                    .foregroundStyle(.black)
                    .annotation(position: .trailing) {
                        ZStack {
                            let specifier = progress > 10 ? "%.0f" : "%.1f"
                            Text("\(progress, specifier: specifier)\(unit.rawValue)")
                                .font(.caption)
                                .foregroundStyle(.white)
                                .padding(1)
                                .background {
                                    RoundedRectangle(cornerRadius: 2).fill(.black)
                                }
                        }
                    }
            }.chartXAxis {
                AxisMarks() { value in
                    AxisValueLabel {
                        let number = value.as(Double.self) ?? 0
                        Text("\(number, specifier: "%.0f")\(unit.rawValue)")
                    }
                    AxisGridLine()
                }
            }.chartLegend(.hidden)
                .frame(height: 40)
                .chartXScale(domain: [0, domainEnd])
        }
    }
}

#Preview {
    VStack {
        NutritionalTargetProgress(
            label: NutritionalProperties.getLabelForProperty(\.vitaminA)!,
            target: NutritionalProperties.getTargetForProperty(\.vitaminA)!,
            unit: NutritionUnit.microgram,
            progress: 380.7
        )
        NutritionalTargetProgress(
            label: NutritionalProperties.getLabelForProperty(\.vitaminB12)!,
            target: NutritionalProperties.getTargetForProperty(\.vitaminB12)!,
            unit: NutritionUnit.microgram,
            progress: 10.4
        )
    }
}
