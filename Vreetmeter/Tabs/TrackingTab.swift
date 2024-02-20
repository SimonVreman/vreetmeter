
import SwiftUI

struct TrackingTab: View {
    @Environment(\.scenePhase) private var scenePhase
    @State private var navigation = TrackingNavigationState()
    
    var body: some View {
        VStack(spacing: 0) {
            NavigationStack(path: $navigation.selectionPath) {
                DailyView()
                    .navigationDestination(for: Meal.self) { meal in
                        MealView(meal: meal).onAppear { navigation.meal = meal }
                            .onDisappear { navigation.meal = Meal.getAutomaticMeal() }
                    }.background {
                        GradientBackground(colors: [.orange, .green, .blue]).ignoresSafeArea()
                    }
            }
            
            Spacer(minLength: 0)
        
            Divider()
        
            QuickProductSearch()
                .padding([.horizontal], 16).padding([.vertical], 8)
                .background(.regularMaterial)
        }.onChange(of: scenePhase) { _, phase in
            switch phase {
             case .active:
                 navigation.meal = Meal.getAutomaticMeal()
             default:
                 break
            }
        }.environment(navigation)
    }
}
