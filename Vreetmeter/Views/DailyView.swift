
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
        if (!refresh && consumptions.currentDayFetched) { return }
        try? await consumptions.fetchDayConsumptions()
        try? await health.synchronizeConsumptions(day: navigation.date, consumptions: consumptions.dayConsumptions)
    }
    
    func changeDate(offset: Int) {
        if let date = Calendar.current.date(byAdding: .day, value: offset, to: navigation.date) {
            consumptions.day = date
            navigation.date = date
            Task { await fetchData(refresh: false) }
        }
    }
    
    var body: some View {
        VStack(spacing: 0) {
            let consumptionList = consumptions.dayConsumptions
            if (consumptions.currentDayFetched) {
                // TODO figure something out for missing bodymass
                DailySummary(bodyMass: bodyMass ?? 75, energyGoal: energyGoal, consumptions: consumptionList)
                    .padding([.horizontal, .bottom], 16)
                    .background(Color(UIColor.secondarySystemGroupedBackground))
                Divider()
                ScrollView {
                    DailyConsumptionList(consumptions: consumptionList).padding(16)
                }.refreshable { await fetchData(refresh: true) }
            } else {
                ProgressView().frame(maxWidth: .infinity, maxHeight: .infinity)
            }
        }.onAppear {
            Task { await fetchData(refresh: false) }
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
        }.navigationTitle(consumptions.day.formatted(.dateTime.weekday(.wide).month(.wide).day()))
            .background(Color(UIColor.systemGroupedBackground))
            .navigationBarTitleDisplayMode(.inline)
                
    }
}
