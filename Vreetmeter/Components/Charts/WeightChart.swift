
import SwiftUI
import Charts

struct WeightChart: View {
    var domain: [Date]
    var data: [NumericalDatePoint]
    var zones: Int
    
    private var minY: Double {
        data.min(by: { $0.value < $1.value })?.value ?? 0
    }
    
    private var maxY: Double {
        data.min(by: { $0.value > $1.value })?.value ?? 0
    }
    
    private var yPadding: Double {
        return (maxY - minY) / 10
    }
    
    private var zoneWidth: TimeInterval {
        domain[0].distance(to: domain[1]).scaled(by: 1 / Double(zones))
    }
    
    var body: some View {
        Chart {
            
            // Mark zones
            ForEach(0..<zones, id: \.self) { zone in
                let offset = zoneWidth.scaled(by: Double(zone))
                let startX = domain[0].addingTimeInterval(offset)
                let endX = startX.addingTimeInterval(zoneWidth)
                
                RectangleMark(
                    xStart: .value("Zone X start", startX),
                    xEnd: .value("Zone X end", endX),
                    yStart: .value("Zone Y start", minY - yPadding),
                    yEnd: .value("Zone Y end", maxY + yPadding * 3)
                ).annotation(position: .overlay, alignment: .top, spacing: 0) {
                    let average = data.filter { $0.date >= startX && $0.date < endX }.average()
                    
                    VStack {
                        Text("\(zone + 1)").fontWeight(.light).foregroundStyle(.secondary)
                        
                        Text(average != nil ? "\(average!, specifier: "%.1f")" : "--.-")
                            .fontDesign(.rounded) +
                        Text("kg").foregroundStyle(.secondary)
                    }.font(.headline).fontWeight(.semibold)
                }.foregroundStyle(.blue.opacity(zone % 2 == 0 ? 0 : 0.2))
            }
            
            // Line and points
            ForEach(data, id: \.date) {
                LineMark(
                    x: .value("Day", $0.date),
                    y: .value("Weight", $0.value)
                ).foregroundStyle(.red)
                PointMark(
                    x: .value("Day", $0.date),
                    y: .value("Weight", $0.value)
                ).foregroundStyle(.red)
            }
            
        }.chartXAxis {
            AxisMarks(format: Date.FormatStyle().day(.defaultDigits))
        }.chartYAxis(.hidden)
            .chartYScale(domain: [minY - yPadding, maxY + yPadding * 3])
            .chartXScale(domain: domain)
    }
}

#Preview {
    WeightChart(
        domain: [Calendar.current.date(byAdding: .day, value: -28, to: Date.now)!, Date.now],
        data: [
            NumericalDatePoint(date: Calendar.current.date(byAdding: .day, value: -2, to: Date.now)!, value: 70),
            NumericalDatePoint(date: Calendar.current.date(byAdding: .day, value: -8, to: Date.now)!, value: 450),
            NumericalDatePoint(date: Calendar.current.date(byAdding: .day, value: -17, to: Date.now)!, value: 200),
        ],
        zones: 4
    )
}
