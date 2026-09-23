
import SwiftUI

struct GuessSheet: View {
    @Environment(EetmeterAPI.self) var eetmeterAPI
    @Environment(ConsumptionState.self) var consumptions
    @Environment(TrackingNavigationState.self) var navigation
    @Environment(HealthState.self) var health
    @State var busy: Bool = false
    @State var calories: Double = 500
    @State var fatScore: Double = 0.3
    @State var proteinScore: Double = 0.25
    
    // Fat is a share of all calories, protein a share of the non-fat calories, carbs the remainder
    var fatGrams: Double { calories * fatScore / 9 }
    var proteinGrams: Double { calories * (1 - fatScore) * proteinScore / 4 }
    var carbGrams: Double { calories * (1 - fatScore) * (1 - proteinScore) / 4 }
    
    func save() {
        busy = true
        Task { do {
            let meal = navigation.meal!
            let date = navigation.date.startOfDay
            try await eetmeterAPI.saveGuess(update: Eetmeter.GuessUpdate(
                period: meal.id,
                date: date,
                energy: calories,
                protein: proteinGrams,
                fat: fatGrams,
                carbs: carbGrams
            ))
            try await consumptions.fetchForDay(date, tryCache: false)
            try await health.synchronizeConsumptions(day: date, consumptions: consumptions.getAllForDay(date))
            navigation.consumptionSubmit.toggle()
        } catch {
            busy = false
        } }
    }
    
    func isValid() -> Bool {
        return !busy && calories > 1 && calories < 5000
    }
    
    var body: some View {
        VStack(spacing: 0) {
            VStack(spacing: 8) {
                GroupBox {
                    MacroSummary(
                        amount: 100,
                        energie: calories,
                        eiwit: proteinGrams,
                        koolhydraten: carbGrams,
                        vet: fatGrams
                    )
                }.backgroundStyle(Color(UIColor.secondarySystemGroupedBackground))
                    .padding([.leading, .trailing], 16)
                
                GuessForm(
                    calories: $calories,
                    fatScore: $fatScore,
                    proteinScore: $proteinScore
                ).frame(height: 250).padding(Edge.Set.top, -34)
            }
            
            Spacer()
            
            Button(action: save, label: { Text("Enter") })
                .buttonStyle(ActionButtonStyle(disabled:  !isValid()))
                .disabled(!isValid())
                .padding(.top, 8)
                .ignoresSafeArea()
        }.padding(.top, 16)
            .background(Color(UIColor.systemGroupedBackground))
    }
}

#Preview {
    VStack { }
        .sheet(isPresented: .constant(true)) {
            GuessSheet()
        }
}
