
import SwiftUI
import HealthKit

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
                TrackingTab().tabItem { Label("Tracking", systemImage: "pencil.and.list.clipboard") }
                ProgressTab().tabItem { Label("Progress", systemImage: "chart.xyaxis.line") }
                MealsTab().tabItem { Label("Meals", systemImage: "stove") }
                FavoritesTab().tabItem { Label("Favorites", systemImage: "star") }
                SettingsTab().tabItem { Label("Settings", systemImage: "gear") }
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
