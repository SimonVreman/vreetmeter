
import SwiftUI

struct TrackingTab: View {
    @State private var navigation = TrackingNavigationState()
    
    var body: some View {
        NavigationStack(path: $navigation.selectionPath) {
            DailyView()
                .navigationDestination(for: Meal.self) { meal in
                    MealView(meal: meal).onAppear { navigation.meal = meal }
                }.navigationDestination(for: Eetmeter.GenericProduct.self) { product in
                    ProductView(product: product)
                }.navigationDestination(for: ConsumptionSearch.self) { search in
                    SelectConsumptionView(search: search)
                }
        }.environment(navigation)
    }
}
