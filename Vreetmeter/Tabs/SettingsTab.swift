
import SwiftUI

enum SettingsDestination: Hashable {
    case favorites
    case combinedProducts
}

struct SettingsTab: View {
    var body: some View {
        NavigationStack {
            SettingsList().navigationTitle("Settings")
                .navigationDestination(for: SettingsDestination.self) { destination in
                    switch (destination) {
                    case .favorites:
                        FavoritesView()
                    case .combinedProducts:
                        CombinedProductsView()
                    }
                }
        }
    }
}
