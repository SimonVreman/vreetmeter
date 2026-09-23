
import SwiftUI

struct CombinedProductsTab: View {
    @Environment(\.scenePhase) private var scenePhase
    @State private var selectionPath = NavigationPath()
    
    var body: some View {
        ZStack {
            NavigationStack(path: $selectionPath) {
                ScrollView { CombinedProductsView() }
                    .navigationDestination(for: CombinedProduct.self) { product in
                        CombinedProductEditView(product: product)
                    }
                    .background {
                        GradientBackground(colors: [.orange, .green, .blue]).ignoresSafeArea()
                    }
            }
        }
    }
}
