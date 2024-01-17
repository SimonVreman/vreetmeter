
import SwiftUI

struct QuickProductSearch: View {
    @Environment(TrackingNavigationState.self) var navigation
    @State private var showSearchSheet = false
    @State private var showGuessSheet = false
    @State private var showScanSheet = false
    @State private var selectedMeal: Meal = .snack
    
    private var meal: Binding<Meal> { Binding(
        get: { self.selectedMeal },
        set: { updateMeal(meal: $0) }
    )}
    
    private let buttonSize: CGFloat = 40
    
    private func updateMeal(meal: Meal) {
        self.navigation.meal = meal
        self.selectedMeal = meal
    }
    
    private func getAutomaticMeal() -> Meal {
        let time = Date.now
        let breakfast = Meal.breakfast.getTimeOfDay(day: time)
        let lunch = Meal.breakfast.getTimeOfDay(day: time)
        let dinner = Meal.breakfast.getTimeOfDay(day: time)
        
        if time > breakfast.start && time < breakfast.end {
            return .breakfast
        } else if time > lunch.start && time < lunch.end {
            return .lunch
        } else if time > dinner.start && time < dinner.end {
            return .dinner
        }
        
        return .snack
    }
    
    var body: some View {
        HStack(spacing: 8) {
            HStack {
                Menu {
                    Picker("", selection: meal) {
                        ForEach(Meal.allCases) {
                            Label($0.getLabel(), systemImage: $0.getIcon()).tag($0)
                        }
                    }
                } label: {
                    Image(systemName: self.selectedMeal.getIcon()).foregroundStyle(self.selectedMeal.getColor())
                }
            }.frame(width: buttonSize)
            
            HStack(spacing: 4) {
                Image(systemName: "magnifyingglass")
                Text("Search")
                Spacer()
            }.frame(height: buttonSize).padding([.horizontal], 8).background {
                RoundedRectangle(cornerRadius: 8).fill(.gray.quinary)
            }.foregroundStyle(.secondary).onTapGesture {
                showSearchSheet.toggle()
            }
            
            Button { showGuessSheet.toggle() } label: { Image(systemName: "questionmark.square") }
                .frame(width: buttonSize, height: buttonSize)
                .background { RoundedRectangle(cornerRadius: 8).fill(.gray.quinary) }
            
            Button { showScanSheet.toggle() } label: { Image(systemName: "barcode.viewfinder") }
                .frame(width: buttonSize, height: buttonSize)
                .background { RoundedRectangle(cornerRadius: 8).fill(.gray.quinary) }
        }.sheet(isPresented: $showSearchSheet) {
            NavigationStack {
                SelectConsumptionView(search: ConsumptionSearch(meal: selectedMeal), hideQuickActions: true)
                    .navigationDestination(for: Eetmeter.GenericProduct.self) { product in
                    ProductView(product: product)
                }
            }
        }.sheet(isPresented: $showGuessSheet) {
            GuessSheet()
        }.sheet(isPresented: $showScanSheet) {
            BarcodeScannerSheet()
        }.onAppear {
            self.updateMeal(meal: self.getAutomaticMeal())
        }.onChange(of: navigation.consumptionSubmit) {
            showGuessSheet = false
            showScanSheet = false
        }.frame(height: buttonSize)
    }
}

#Preview {
    VStack {
        NavigationView {
            VStack {
                QuickProductSearch().padding(.horizontal)
            }
        }
    }
}
