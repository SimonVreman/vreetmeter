
import SwiftUI

struct TrackingTab: View {
    @Environment(\.scenePhase) private var scenePhase
    @State private var navigation = TrackingNavigationState()
    
    var body: some View {
        ZStack {
            NavigationStack(path: $navigation.selectionPath) {
                DailyView()
                    .navigationDestination(for: Meal.self) { meal in
                        MealView(meal: meal)
                            .onAppear { navigation.meal = meal }
                            .onDisappear {
                                if (navigation.selectionPath.count == 0) {
                                    navigation.meal = Meal.getAutomaticMeal()
                                } else if (navigation.selectionPath.count == 2) {
                                    navigation.meal = meal
                                }
                            }.safeAreaInset(edge: .bottom) {
                                Color.clear.frame(height: 64)
                            }
                    }.navigationDestination(for: Eetmeter.GenericProduct.self) { product in
                        ProductView(product: product)
                    }.background {
                        GradientBackground(colors: [.orange, .green, .blue]).ignoresSafeArea()
                    }.safeAreaInset(edge: .bottom) {
                        Color.clear.frame(height: 64)
                    }
            }
            
            if (navigation.selectionPath.count <= 1) {
                VStack(spacing: 0) {
                    Spacer()
                
                    QuickProductSearch()
                        .padding([.horizontal], 20).padding([.vertical], 8)
                }
            }
        }.onChange(of: scenePhase) { _, phase in
            switch phase {
            case .active:
                if (navigation.onDailyView) {
                    navigation.meal = Meal.getAutomaticMeal()
                    navigation.date = .now.startOfDay
                }
            default:
                break
            }
        }.environment(navigation)
    }
}
