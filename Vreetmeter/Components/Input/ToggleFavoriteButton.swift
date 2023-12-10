
import SwiftUI

struct ToggleFavoriteButton: View {
    @Environment(EetmeterAPI.self) var eetmeter
    var update: Eetmeter.FavoriteUpdate
    
    @State private var loading: Bool = false
    private var favorite: Eetmeter.Favorite? {
        eetmeter.favorites.first {
            if update.brandProductID != nil {
                return update.brandProductID == $0.brandProductId && update.productUnitID == $0.productUnitId
            } else if update.combinedProductID != nil {
                return update.combinedProductID == $0.combinedProductId
            } else {
                return update.productUnitID == $0.productUnitId
            }
        }
    }
    
    func toggle() async throws {
        if loading { return }
        loading = true
        if favorite != nil {
            try await eetmeter.deleteFavorite(id: favorite!.id)
        } else {
            try await eetmeter.saveFavorite(update: update)
        }
        loading = false
    }
    
    var body: some View {
        Button(action: { Task { try await toggle() } }) {
            Image(systemName: favorite != nil ? "star.fill" : "star")
        }
    }
}
