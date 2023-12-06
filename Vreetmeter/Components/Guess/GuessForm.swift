
import SwiftUI

struct GuessForm: View {
    enum FocusedField { case calories }
    
    @Binding var calories: Double
    @Binding var carbs: Double
    @Binding var protein: Double
    @Binding var fat: Double
    
    @FocusState private var focusedField: FocusedField?
    
    var body: some View {
        Form {
            Section {
                Slider(value: $carbs, in: 0.1...99.8, step: 0.1).tint(.blue)
                    .task(id: carbs) {
                        let difference = carbs + protein + fat - 100
                        let proteinDifference = difference * (protein / (protein + fat))
                        let fatDifference = difference * (fat / (protein + fat))
                        
                        protein -= proteinDifference
                        fat -= fatDifference
                    }
                Slider(value: $protein, in: 0.1...99.8, step: 0.1).tint(.green)
                    .task(id: protein) {
                        let difference = carbs + protein + fat - 100
                        let carbsDifference = difference * (carbs / (carbs + fat))
                        let fatDifference = difference * (fat / (carbs + fat))
                        
                        carbs -= carbsDifference
                        fat -= fatDifference
                    }
                Slider(value: $fat, in: 0.1...99.8, step: 0.1).tint(.orange)
                    .task(id: fat) {
                        let difference = carbs + protein + fat - 100
                        let carbsDifference = difference * (carbs / (carbs + protein))
                        let proteinDifference = difference * (protein / (carbs + protein))
                        
                        carbs -= carbsDifference
                        protein -= proteinDifference
                    }
                LabeledContent {
                    TextField("0", value: $calories, formatter: NumberFormatter()).keyboardType(.decimalPad)
                        .fixedSize(horizontal: true, vertical: false)
                        .focused($focusedField, equals: .calories)
                        .onAppear { focusedField = .calories }
                } label: {
                    Text("Calories")
                }
            }
        }.scrollContentBackground(.hidden)
            .scrollDisabled(true)
    }
}


#Preview {
    GuessForm(
        calories: .constant(500),
        carbs: .constant(40),
        protein: .constant(40),
        fat: .constant(20)
    ).padding(16)
}
