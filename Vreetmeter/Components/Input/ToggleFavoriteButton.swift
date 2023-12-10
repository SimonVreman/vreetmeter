
import SwiftUI

struct AddFavoriteButton: View {
    @Environment(EetmeterAPI.self) var eetmeter
    var update: Eetmeter.FavoriteUpdate
    var id: UUID?
    
    private var isFavorite: Bool {
        eetmeter.favorites.contains { $0.id == id }
    }
    
    func toggle() async throws {
        if isFavorite {
            
        }
        eetmeter.saveFavorite(update: update)
    }
    
    var body: some View {
        Button(action: { Task { toggle() } }) {
            Image(systemName: isFavorite ? "star.fill" : "star")
        }
    }
}
