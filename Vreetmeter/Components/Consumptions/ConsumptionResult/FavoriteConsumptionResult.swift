
import SwiftUI

struct FavoriteConsumptionResult: View {
    var label: String
    var sublabel: String
    
    var body: some View {
        ConsumptionResult(
            label: label,
            sublabel: sublabel,
            icon: AnyView(Image(systemName: "star.fill").foregroundColor(.yellow))
        )
    }
}
