
import SwiftUI

var MINIMUM_FRACTION: Double = 0.1
var MAXIMUM_FRACTION: Double = 100 - 2 * MINIMUM_FRACTION

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
                Slider(value: $carbs, in: MINIMUM_FRACTION...MAXIMUM_FRACTION, step: MINIMUM_FRACTION).tint(.blue)
                    .onChange(of: carbs) {
                        let difference = 100 - (carbs + protein + fat)
                        let proteinDifference = max(difference, MINIMUM_FRACTION - protein)
                        
                        protein += proteinDifference
                        fat += difference - proteinDifference
                    }
                Slider(value: $protein, in: MINIMUM_FRACTION...MAXIMUM_FRACTION, step: MINIMUM_FRACTION).tint(.green)
                    .onChange(of: protein) {
                        let difference = 100 - (carbs + protein + fat)
                        let fatDifference = max(difference, MINIMUM_FRACTION - fat)
                        
                        fat += fatDifference
                        carbs += difference - fatDifference
                    }
                Slider(value: $fat, in: MINIMUM_FRACTION...MAXIMUM_FRACTION, step: MINIMUM_FRACTION).tint(.orange)
                    .onChange(of: fat) {
                        let difference = 100 - (carbs + protein + fat)
                        let proteinDifference = max(difference, MINIMUM_FRACTION - protein)
                        
                        protein += proteinDifference
                        carbs += difference - proteinDifference
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
