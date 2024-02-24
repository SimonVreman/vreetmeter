
import SwiftUI

struct CombinedProductsView: View {
    @Environment(ProductState.self) var products
    
    @State private var query: String = ""
    
    private var results: [CombinedProduct] {
        if query.isEmpty { return products.combinedProducts }
        return products.combinedProducts.filter { c in
            c.name.localizedCaseInsensitiveContains(query)
        }
    }
    
    var body: some View {
        List {
            ForEach(results, id: \.id) { product in
                CombinedConsumptionResult(label: product.name)
            }
        }.searchable(text: $query)
            .navigationTitle("Combined products")
    }
}
