
import SwiftUI

@main
struct VreetmeterApp: App {
    @State private var eetmeterAPI: EetmeterAPI
    @State private var consumptions: ConsumptionState
    @State private var products: ProductState
    @State private var health: HealthState
    @State private var settings: SettingsState
    
    @State private var showLoginSheet: Bool = false
    @State private var initialLoad: Bool = true
    
    init() {
        let api = EetmeterAPI()
        self.eetmeterAPI = api
        self.consumptions = ConsumptionState(api: api)
        self.products = ProductState(api: api)
        self.health = HealthState()
        self.settings = SettingsState()
    }
        
    var body: some Scene {
        WindowGroup {
            TabView {
                Tab("Tracking", systemImage: "pencil.and.list.clipboard") { TrackingTab() }
                Tab("Progress", systemImage: "chart.xyaxis.line") { ProgressTab() }
                Tab("Nutrients", systemImage: "gauge.with.needle") { NutrientsTab() }
                Tab("Recipes", systemImage: "stove.fill") { CombinedProductsTab() }
                Tab("Settings", systemImage: "gear") { SettingsTab() }
            }.onAppear {
                if !initialLoad { return }
                initialLoad = false
                showLoginSheet = !eetmeterAPI.loggedIn
                Task { try await health.requestPermission() }
                Task { try await products.fetchCombinedProducts() }
            }.sheet(isPresented: $showLoginSheet) {
                LoginSheet()
            }.environment(eetmeterAPI)
                .environment(consumptions)
                .environment(products)
                .environment(health)
                .environment(settings)
        }
    }
}
