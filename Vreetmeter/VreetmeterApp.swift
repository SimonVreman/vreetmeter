
import SwiftUI
import HealthKit

@main
struct VreetmeterApp: App {
    @StateObject private var eetmeterAPI: EetmeterAPI
    @StateObject private var navigation = NavigationState()
    @State private var consumptions: ConsumptionState
    @State private var products: ProductState
    @State private var health: HealthState
    @State private var settings: SettingsState
    
    init() {
        let api = EetmeterAPI()
        self._eetmeterAPI = StateObject(wrappedValue: api)
        self.consumptions = ConsumptionState(api: api)
        self.products = ProductState(api: api)
        self.health = HealthState()
        self.settings = SettingsState()
    }
        
    var body: some Scene {
        WindowGroup {
            TabView {
                TrackingTab().tabItem { Label("Tracking", systemImage: "pencil.and.list.clipboard") }
                ProgressTab().tabItem { Label("Progress", systemImage: "chart.xyaxis.line") }
                MealsTab().tabItem { Label("Meals", systemImage: "stove") }
                SettingsTab().tabItem { Label("Settings", systemImage: "gear") }
            }
                .environmentObject(eetmeterAPI)
                .environmentObject(navigation)
                .environment(consumptions)
                .environment(products)
                .environment(health)
                .environment(settings)
                .onAppear {
                    Task { try await health.requestPermission() }
                    Task { try await products.fetchCombinedProducts() }
                }
        }
    }
}
