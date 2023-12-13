
import SwiftUI

struct ProgressTab: View {
    @Environment(HealthState.self) var health
    @State private var data: [NumericalDatePoint]?
    
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
        NavigationView {
            if data == nil {
                ProgressView().centered()
            } else {
                HStack {
                    VStack {
                        WeightChartCard(data: data!)
                        
                        WeightTrendCard(data: data!)
                        
                        Spacer()
                    }.padding()
                }.navigationTitle("Progress")
            }
        }.onAppear { Task { try? await self.load() } }
    }
}

#Preview {
    ProgressTab()
        .environment(HealthState())
}
