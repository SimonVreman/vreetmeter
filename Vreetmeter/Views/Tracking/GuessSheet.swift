
import SwiftUI

struct GuessSheet: View {
    @Environment(EetmeterAPI.self) var eetmeterAPI
    @Environment(ConsumptionState.self) var consumptions
    @Environment(TrackingNavigationState.self) var navigation
    @Environment(HealthState.self) var health
    @Environment(\.dismiss) var dismiss
    @State var busy: Bool = false
    @State var calories: Double
    @State var fatScore: Double
    @State var proteinScore: Double
    
    /// The guess being edited, or nil when making a new guess
    var guess: GuessConsumption?
    
    init(guess: GuessConsumption? = nil) {
        self.guess = guess
        
        // Derive the scores back from the stored grams
        let calories = guess?.energy ?? 500
        let fatCalories = (guess?.fat ?? 0) * 9
        let restCalories = calories - fatCalories
        let fatScore = guess != nil && calories > 0 ? fatCalories / calories : 0.3
        let proteinScore = guess != nil && restCalories > 0 ? guess!.protein * 4 / restCalories : 0.25
        
        self._calories = State(initialValue: calories)
        self._fatScore = State(initialValue: fatScore.clamped(to: FAT_SCORE_RANGE))
        self._proteinScore = State(initialValue: proteinScore.clamped(to: PROTEIN_SCORE_RANGE))
    }
    
    // Fat is a share of all calories, protein a share of the non-fat calories, carbs the remainder
    var fatGrams: Double { calories * fatScore / 9 }
    var proteinGrams: Double { calories * (1 - fatScore) * proteinScore / 4 }
    var carbGrams: Double { calories * (1 - fatScore) * (1 - proteinScore) / 4 }
    
    func save() {
        busy = true
        Task { do {
            let meal = guess?.meal ?? navigation.meal!
            let date = (guess?.date ?? navigation.date).startOfDay
            try await eetmeterAPI.saveGuess(update: Eetmeter.GuessUpdate(
                id: guess?.id,
                period: meal.id,
                date: date,
                energy: calories,
                protein: proteinGrams,
                fat: fatGrams,
                carbs: carbGrams
            ))
            try await consumptions.fetchForDay(date, tryCache: false)
            try await health.synchronizeConsumptions(day: date, consumptions: consumptions.getAllForDay(date))
            // New guesses close the whole add flow, edits only close this sheet
            if guess == nil { navigation.consumptionSubmit.toggle() } else { dismiss() }
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
                )
            }
            
            Button(action: save, label: { Text(guess == nil ? "Enter" : "Save") })
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
