
import SwiftUI

struct ProductView: View {
    @EnvironmentObject var eetmeterAPI: EetmeterAPI
    @Environment(ProductState.self) var products
    @State var product: Eetmeter.GenericProduct
    @State var brandProduct: Eetmeter.BrandProduct?
    @State var baseProduct: Eetmeter.BaseProduct?
    @State var combinedProduct: CombinedProduct?
    
    func getConsumption() {
        // Transform favorite to correct type
        if (product.type == .favorite) {
            let favorite = eetmeterAPI.favorites.first(where: { f in f.id == product.id })!
            
            if (favorite.combinedProductId != nil) {
                product.type = .combined
                product.id = favorite.combinedProductId!
            } else if (favorite.brandProductId != nil) {
                product.type = .brand
                product.id = favorite.brandProductId!
            } else {
                product.type = .general
            }
        }
        
        if (product.type == .combined) {
            combinedProduct = products.combinedProducts.first(where: { c in c.id == product.id })
        } else if (product.type == .brand) { Task { @MainActor in
            brandProduct = try await eetmeterAPI.getBrandProduct(id: product.id)
        }} else { Task { @MainActor in
            do {
                baseProduct = try await eetmeterAPI.getBaseProduct(id: product.id, isUnit: product.type == .unit)
            } catch let e {
                print(e)
            }
        }}
    }
    
    var body: some View {
        VStack {
            if (baseProduct != nil) {
                let nutrition: EetmeterNutritional = baseProduct!.products.first!.preparationVariants.first!.product
                SingleProductView(baseNutrition: nutrition, products: baseProduct!.products, productName: baseProduct!.name)
            } else if (brandProduct != nil) {
                SingleProductView(baseNutrition: brandProduct!, products: [brandProduct!.product], productName: brandProduct!.productName, brandProductId: brandProduct!.id)
            } else if (combinedProduct != nil) {
                CombinedProductView(product: combinedProduct!)
            } else {
                ProgressView()
            }
        }.onAppear { getConsumption() }
            .navigationBarTitleDisplayMode(.inline)
            .background(Color(UIColor.systemGroupedBackground))
    }
}
