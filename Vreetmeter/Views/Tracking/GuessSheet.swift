
import SwiftUI

struct GuessSheet: View {
    @Environment(EetmeterAPI.self) var eetmeterAPI
    @Environment(ConsumptionState.self) var consumptions
    @Environment(TrackingNavigationState.self) var navigation
    @Environment(HealthState.self) var health
    @State var busy: Bool = false
    @State var calories: Double = 500
    @State var carbs: Double = 40
    @State var protein: Double = 40
    @State var fat: Double = 20
    
    func save() {
        busy = true
        Task { do {
            let meal = navigation.meal!
            let date = navigation.date.startOfDay
            try await eetmeterAPI.saveGuess(update: Eetmeter.GuessUpdate(
                period: meal.id,
                date: date,
                energy: calories,
                protein: protein / 100 * calories / 4,
                fat: fat / 100 * calories / 9,
                carbs: carbs / 100 * calories / 4
            ))
            try await consumptions.fetchForDay(date, tryCache: false)
            try await health.synchronizeConsumptions(day: date, consumptions: consumptions.getAllForDay(date))
            DispatchQueue.main.async {
                navigation.consumptionSubmit.toggle()
            }
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
                        eiwit: protein / 100 * calories / 4,
                        koolhydraten: carbs / 100 * calories / 4,
                        vet: fat / 100 * calories / 9
                    )
                }.backgroundStyle(Color(UIColor.secondarySystemGroupedBackground))
                    .padding([.leading, .trailing], 16)
                
                GuessForm(
                    calories: $calories,
                    carbs: $carbs,
                    protein: $protein,
                    fat: $fat
                ).frame(height: 211).padding(Edge.Set.top, -34)
            }
            
            Spacer()
            
            Button(action: save, label: { Text("Enter") })
                .buttonStyle(ActionButtonStyle(disabled:  !isValid()))
                .disabled(!isValid())
                .padding([.leading, .trailing], 16)
                .padding(.top, 8)
        }.padding([.top, .bottom], 16)
            .background(Color(UIColor.systemGroupedBackground))
    }
}

#Preview {
    VStack { }
        .sheet(isPresented: .constant(true)) {
            GuessSheet()
        }
}
