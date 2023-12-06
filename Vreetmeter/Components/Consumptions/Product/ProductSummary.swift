
import SwiftUI

struct ProductSummary: View {
    var name: String
    var brand: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            Text(name).font(.title).bold().lineLimit(2).truncationMode(.tail)
            Text(brand).foregroundColor(.secondary).bold()
        }
    }
}

#Preview {
    ProductSummary(name: "Product name", brand: "Brand name")
}
