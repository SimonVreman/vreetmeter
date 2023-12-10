
import SwiftUI

struct FavoritesTab: View {
    @Environment(EetmeterAPI.self) var eetmeter
    
    @State private var query: String = ""
    
    private var results: [Eetmeter.Favorite] {
        if query.isEmpty { return eetmeter.favorites }
        return eetmeter.favorites.filter { f in
            f.productName.localizedCaseInsensitiveContains(query) || f.brandName.localizedCaseInsensitiveContains(query)
        }
    }
    
    func delete(indexes: IndexSet) {
        // only support one delete
        if (indexes.isEmpty) { return }
        let index = indexes.first!
        if (results.count <= index) { return }
        let favorite = results[index]
        Task { try await eetmeter.deleteFavorite(id: favorite.id) }
    }
    
    var body: some View {
        NavigationView {
            List {
                ForEach(results, id: \.id) { favorite in
                    FavoriteConsumptionResult(label: favorite.productName, sublabel: favorite.brandName)
                }.onDelete(perform: delete)
            }.searchable(text: $query)
                .navigationTitle("Favorites")
        }
    }
}
