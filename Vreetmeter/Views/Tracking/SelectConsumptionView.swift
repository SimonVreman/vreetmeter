
import SwiftUI
import DebouncedOnChange

struct ConsumptionSearch: Hashable {
    let meal: Meal
}

struct SelectConsumptionView: View {
    @Environment(EetmeterAPI.self) var eetmeterAPI
    @Environment(ProductState.self) var products
    @State private var query: String = ""
    @State private var searchOpen: Bool = true
    @State private var results: [Eetmeter.GenericProduct] = []
    @State private var searching: Bool = true
    @State var useBarcode: Bool = false
    @State var makeGuess: Bool = false
    var search: ConsumptionSearch
    var hideQuickActions: Bool = false
    
    func filterLocally(items: [Eetmeter.GenericProduct], query: String) -> [Eetmeter.GenericProduct] {
        if (query.isEmpty) { return items }
        return items.filter { i in
            i.label!.localizedCaseInsensitiveContains(query) || i.sublabel!.localizedCaseInsensitiveContains(query)
        }
    }
    
    func favoriteToGeneric(favorite: Eetmeter.Favorite) -> Eetmeter.GenericProduct {
        return Eetmeter.GenericProduct(id: favorite.id, type: .favorite, label: favorite.productName, sublabel: favorite.brandName)
    }
    
    func combinedToGeneric(combined: CombinedProduct) -> Eetmeter.GenericProduct {
        return Eetmeter.GenericProduct(id: combined.id, type: .combined, label: combined.name, sublabel: "Eigen gerecht")
    }
    
    func otherToGeneric(other: Eetmeter.ConsumptionSearchResult) -> Eetmeter.GenericProduct {
        return Eetmeter.GenericProduct(id: other.id, type: other.type == 4 ? .brand : .general, label: other.productName, sublabel: other.brandName ?? "Algemeen")
    }
    
    func search(query: String) async throws -> [Eetmeter.GenericProduct] {
        var results = filterLocally(items: eetmeterAPI.favorites.map(favoriteToGeneric), query: query)
        let combinedResults = filterLocally(items: products.combinedProducts.map(combinedToGeneric), query: query)
        
        results.append(contentsOf: combinedResults.filter { c in
            !eetmeterAPI.favorites.contains { f in f.combinedProductId == c.id }
        })
        
        if (query.isEmpty) { return results }
        
        var uniqueSearchResults: Set<UUID> = Set()
        let searched = try await eetmeterAPI.searchConsumptions(query: query)
        
        results.append(contentsOf: searched.compactMap { (result) -> Eetmeter.GenericProduct? in
            guard !uniqueSearchResults.contains(result.id) else { return nil }
            guard !(eetmeterAPI.favorites.contains { f in f.id == result.id }) else { return nil }
            uniqueSearchResults.insert(result.id)
            return otherToGeneric(other: result)
        })
        
        return results
    }
    
    func scheduleSearch(query: String) {
        searching = true
        Task {
            results = try await search(query: query)
            searching = false
        }
    }
    
    var body: some View {
        VStack(spacing: 0) {
            ZStack {
                List {
                    ForEach(results, id: \.id) { result in
                        NavigationLink(value: result) {
                            switch (result.type) {
                                case .favorite: FavoriteConsumptionResult(label: result.label!, sublabel: result.sublabel!)
                                case .combined: CombinedConsumptionResult(label: result.label!)
                                default: GeneralConsumptionResult(label: result.label!, sublabel: result.sublabel!)
                            }
                        }
                    }
                }.searchable(text: $query, isPresented: $searchOpen)
                    .onAppear(perform: { scheduleSearch(query: query) })
                    .onChange(of: query, debounceTime: .seconds(0.25)) { newQuery in
                        if (searching) { return }
                        scheduleSearch(query: newQuery)
                    }
                if (results.isEmpty && !searching) {
                    Text("No results").foregroundStyle(.secondary)
                }
                if (searching) {
                    ProgressView()
                }
            }.sheet(isPresented: $useBarcode) {
                BarcodeScannerSheet()
            }.sheet(isPresented: $makeGuess) {
                GuessSheet()
            }.navigationTitle(search.meal.getLabel())
                .navigationBarTitleDisplayMode(.inline)
            
            if (!hideQuickActions) {
                Divider()
                
                HStack(spacing: 0) {
                    Spacer()
                    
                    Button(action: { makeGuess = true }) {
                        Label("Guess", systemImage: "questionmark.square")
                    }.padding(12)
                    
                    Spacer()
                    
                    Button(action: { useBarcode = true }) {
                        Label("Scan", systemImage: "barcode.viewfinder")
                    }.padding(12)
                    
                    Spacer()
                }.background(.regularMaterial)
            }
        }
    }
}

#Preview {
    SelectConsumptionView(search: ConsumptionSearch(meal: .breakfast), hideQuickActions: false)
        .environment(EetmeterAPI())
}
