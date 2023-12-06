
import SwiftUI
import Charts

struct WeightCard: View {
    @Environment(HealthState.self) var health
    @State var data: [NumericalDatePoint] = []
    
    func load() async throws {
        let calendar = Calendar.current
        let end = calendar.date(byAdding: .day, value: 1, to: Date().startOfDay)!
        let start = calendar.date(byAdding: .day, value: -30, to: end)!
        let statistics = try await self.health.queryBodyMass(start: start, end: end, interval: DateComponents(day: 1))
        
        if statistics == nil { return }
        
        let points: [NumericalDatePoint] = statistics!.reduce([]) { points, statistic in
            let date = statistic.startDate
            let bodyMass = statistic.averageQuantity()?.doubleValue(for: .gramUnit(with: .kilo))
            
            if bodyMass == nil { return points }
            
            return points + [NumericalDatePoint(date: date, value: bodyMass!)]
        }
        
        DispatchQueue.main.sync { self.data = points }
    }
    
    var body: some View {
        GroupBox {
            VStack(alignment: .leading) {
                HStack(alignment: .bottom) {
                    let mostRecent = self.data.last?.value
                    Text(mostRecent != nil ? "\(mostRecent!, specifier: "%.1f")" : "--.-")
                        .font(.largeTitle).fontDesign(.rounded).fontWeight(.semibold)
                    + Text("kg").font(.headline).foregroundStyle(.primary.secondary)
                    
                    Text("last 30 days").font(.headline).foregroundStyle(.primary.secondary)
                }
                
                WeightChart(data: data)
            }
        }.backgroundStyle(Color(UIColor.secondarySystemGroupedBackground))
            .frame(height: 300)
            .onAppear { Task { try? await self.load() } }
    }
}
