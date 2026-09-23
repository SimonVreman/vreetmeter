
import SwiftUI

struct QuickProductSearch: View {
    @Environment(TrackingNavigationState.self) private var navigation
    @State private var showSearchSheet = false
    @State private var showGuessSheet = false
    @State private var showScanSheet = false
    
    private var meal: Binding<Meal> { Binding(
        get: { navigation.meal ?? .snack },
        set: { navigation.meal = $0 }
    )}
    
    private let buttonSize: CGFloat = 44
    
    
    var body: some View {
        GlassEffectContainer(spacing: 8) { HStack(spacing: 8) {
            Menu {
                Picker("", selection: meal) {
                    ForEach(Meal.allCases) {
                        Label($0.getLabel(), systemImage: $0.getIcon()).tag($0)
                    }
                }
            } label: {
                let m = meal.wrappedValue
                Image(systemName: m.getIcon()).foregroundStyle(m.getColor())
                    .frame(width: buttonSize, height: buttonSize)
            }.glassEffect(.regular.interactive(), in: .circle)
            
            HStack(spacing: 4) {
                Image(systemName: "magnifyingglass")
                Text("Search")
                Spacer()
            }.frame(height: buttonSize).padding([.horizontal], 16)
                .foregroundStyle(.secondary)
                .contentShape(.capsule)
                .glassEffect(.regular.interactive(), in: .capsule)
                .onTapGesture { showSearchSheet.toggle() }
            
            Button { showGuessSheet.toggle() } label: {
                Image(systemName: "questionmark.square").frame(width: buttonSize, height: buttonSize)
            }.glassEffect(.regular.interactive(), in: .circle)
            
            Button { showScanSheet.toggle() } label: {
                Image(systemName: "barcode.viewfinder").frame(width: buttonSize, height: buttonSize)
            }.glassEffect(.regular.interactive(), in: .circle)
        } }.sheet(isPresented: $showSearchSheet) {
            NavigationStack {
                SelectConsumptionView(search: ConsumptionSearch(meal: meal.wrappedValue), hideQuickActions: true)
                    .navigationDestination(for: Eetmeter.GenericProduct.self) { product in
                    ProductView(product: product)
                }
            }
        }.sheet(isPresented: $showGuessSheet) {
            GuessSheet()
        }.sheet(isPresented: $showScanSheet) {
            BarcodeScannerSheet()
        }.onChange(of: navigation.consumptionSubmit) {
            showGuessSheet = false
            showScanSheet = false
        }.frame(height: buttonSize)
    }
}

#Preview {
    VStack {
        NavigationStack {
            VStack {
                QuickProductSearch().padding(.horizontal)
            }
        }
    }
}
