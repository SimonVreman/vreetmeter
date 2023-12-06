
import SwiftUI

struct TrackingTab: View {
    @EnvironmentObject private var navigation: NavigationState
    
    var body: some View {
        NavigationStack(path: $navigation.selectionPath) {
            DailyView()
                .navigationDestination(for: AnyHashable.self) { item in
                    if let meal = item.base as? Meal {
                        MealView(meal: meal)
                    } else if let product = item.base as? Eetmeter.GenericProduct {
                        ProductView(product: product)
                    } else if let search = item.base as? ConsumptionSearch {
                        SelectConsumptionView(search: search)
                    }
                }
            // Honestly, I've given up. These have to be here for the navigation to be registered,
            // but the one above actually does the rendering...
                .navigationDestination(for: Meal.self) { _ in }
                .navigationDestination(for: Eetmeter.GenericProduct.self) { _ in }
                .navigationDestination(for: ConsumptionSearch.self) { _ in }
        }
    }
}
