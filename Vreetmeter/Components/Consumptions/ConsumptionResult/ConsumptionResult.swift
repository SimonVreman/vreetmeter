
import SwiftUI

struct ConsumptionResult: View {
    var label: String
    var sublabel: String
    var icon: AnyView?
    
    var body: some View {
        HStack {
            if (icon != nil) {
                icon.frame(width: 24).padding([.trailing], 4)
            }
            VStack(alignment: .leading, spacing: -2, content: {
                Text(label)
                Text(sublabel).font(.caption).foregroundColor(.gray)
            }).lineLimit(1)
                .truncationMode(.tail)
        }
    }
}

#Preview {
    List {
        FavoriteConsumptionResult(label: "favorite", sublabel: "some brand")
        FavoriteConsumptionResult(label: "favorite", sublabel: "another brand")
        
        CombinedConsumptionResult(label: "my meal")

        GeneralConsumptionResult(label: "label", sublabel: "general")
        GeneralConsumptionResult(
            label: "very long label that will be truncated",
            sublabel: "brand that is also way too long to be displayed"
        )
    }
}
