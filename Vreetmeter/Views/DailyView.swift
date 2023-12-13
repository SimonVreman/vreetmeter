
import SwiftUI

struct DailyView: View {
    @Environment(EetmeterAPI.self) var eetmeterAPI
    @Environment(TrackingNavigationState.self) var navigation
    @Environment(ConsumptionState.self) var consumptions
    @Environment(SettingsState.self) var settings
    @Environment(HealthState.self) var health
    
    @State var bodyMass: Double?
    var energyGoal: Int { settings.getValue(VMSettings.energyGoal.key) as? Int ?? 2000 }
    
    func fetchData(refresh: Bool) async {
        Task {
            let mass = try await health.queryRecentBodyMass(date: navigation.date)
            DispatchQueue.main.async { bodyMass = mass }
        }
        if (!refresh && consumptions.didFetchForDay(navigation.date)) { return }
        try? await consumptions.fetchForDay(navigation.date)
        try? await health.synchronizeConsumptions(day: navigation.date, consumptions: consumptions.getAllForDay(navigation.date))
    }
    
    func changeDate(offset: Int) {
        if let date = Calendar.current.date(byAdding: .day, value: offset, to: navigation.date) {
            navigation.date = date
            Task { await fetchData(refresh: false) }
        }
    }
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading) {
                Text(navigation.date.formatted(.dateTime.month(.wide).day(.defaultDigits)))
                    .font(.title2).fontWeight(.bold).foregroundStyle(.secondary)
                
                let consumptionList = consumptions.getAllForDay(navigation.date)
                if (consumptions.didFetchForDay(navigation.date) || true) {
                    // TODO figure something out for missing bodymass
                    
                    GroupBox {
                        DailyEnergySummary(bodyMass: bodyMass ?? 75, energyGoal: energyGoal, consumptions: consumptionList)
                    }.cardBackgroundAndShadow()
                    
                    GroupBox {
                        DailyMacroSummary(bodyMass: bodyMass ?? 75, energyGoal: energyGoal, consumptions: consumptionList)
                    }.cardBackgroundAndShadow()
                    
                    DailySchijfVanVijfSummary(consumptions: consumptionList)
                        .compositingGroup()
                        .shadow(color: .black.opacity(0.2), radius: 10)
                    
                    DailyConsumptionList(consumptions: consumptionList)
                        .padding(.top)
                } else {
                    ProgressView().centered()
                }
            }.padding([.horizontal, .bottom], 16)
        }.toolbar {
            ToolbarItem(placement: .topBarLeading) {
                Button(action: { changeDate(offset: -1) }) {
                    Image(systemName: "chevron.left")
                }
            }
            ToolbarItem(placement: .topBarTrailing) {
                Button(action: { changeDate(offset: 1) }) {
                    Image(systemName: "chevron.right")
                }
            }
        }.onAppear { Task { await fetchData(refresh: false) } }
            .refreshable { await fetchData(refresh: true) }
            .navigationTitle(navigation.date.formatted(.dateTime.weekday(.wide)))
    }
}

#Preview {
    NavigationView {
        DailyView()
            .environment(EetmeterAPI())
            .environment(TrackingNavigationState())
            .environment(ConsumptionState(api: EetmeterAPI()))
            .environment(SettingsState())
            .environment(HealthState())
    }
}
