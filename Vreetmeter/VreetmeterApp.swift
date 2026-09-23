
import SwiftUI
import SwiftData

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
                Tab("Workouts", systemImage: "dumbbell") { WorkoutsTab() }
                Tab("Progress", systemImage: "chart.xyaxis.line") { ProgressTab() }
                Tab("Nutrients", systemImage: "gauge.with.needle") { NutrientsTab() }
                Tab("Settings", systemImage: "gear") { SettingsTab() }
            }.onAppear {
                if !initialLoad { return }
                initialLoad = false
                showLoginSheet = !eetmeterAPI.loggedIn
                Task { try await health.requestPermission() }
                Task { try await products.fetchCombinedProducts() }
            }.sheet(isPresented: $showLoginSheet) {
                LoginSheet()
            }.modelContainer(for: [WorkoutProgram.self, WorkoutSession.self, Exercise.self])
                .environment(eetmeterAPI)
                .environment(consumptions)
                .environment(products)
                .environment(health)
                .environment(settings)
        }
    }
}
