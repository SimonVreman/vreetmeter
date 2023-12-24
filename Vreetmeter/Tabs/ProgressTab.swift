
import SwiftUI

struct ProgressTab: View {
    @Environment(HealthState.self) var health
    @State private var data: [NumericalDatePoint]?
    
    private var domain: [Date] {
        let calendar = Calendar.current
        let end = calendar.date(byAdding: .day, value: 1, to: Date().startOfDay)!
        let start = calendar.date(byAdding: .day, value: -28, to: end)!
        return [start, end]
    }
    
    func load() async throws {
        let start = self.domain[0]
        let end = self.domain[1]
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
            ScrollView { VStack(alignment: .leading, spacing: 8) {
                Text("Last 28 days")
                    .font(.title2).fontWeight(.bold)
                    .padding(.bottom, 8)
                
                if data == nil {
                    ProgressView().centered()
                } else {
                    WeightChartCard(domain: domain, data: data!)
                    WeightTrendCard(data: data!)
                }
            }.padding([.horizontal, .bottom]) }.navigationTitle("Progress").background {
                GradientBackground(colors: [.yellow, .red, .brown]).ignoresSafeArea()
            }
        }.onAppear { Task { try? await self.load() } }
    }
}

#Preview {
    ProgressTab()
        .environment(HealthState())
}
