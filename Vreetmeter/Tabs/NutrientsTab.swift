
import SwiftUI

struct NutrientsTab: View {
    var body: some View {
        NavigationView {
            ScrollView {
                NutrientProgressOverview()
            }.navigationTitle("Nutrients").background {
                GradientBackground(colors: [.pink, .mint, .indigo ]).ignoresSafeArea()
            }
        }
    }
}
