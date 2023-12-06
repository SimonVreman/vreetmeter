
import SwiftUI

enum FocusField: Hashable {
    case field
}

struct UnitAmountPicker: View {
    @Binding var amount: Double?
    var isGrams: Bool
    @FocusState private var focusedField: FocusField?
    @State private var fieldAmount: String = ""
    @State private var pickerAmount: Double = 0
    @State private var formatter: NumberFormatter = NumberFormatter()
    
    
    var body: some View {
        VStack {
            LabeledContent {
                TextField("0", text: $fieldAmount).keyboardType(.decimalPad)
                    .fixedSize(horizontal: true, vertical: false)
                    .focused($focusedField, equals: .field)
                    .onAppear { focusedField = .field }
                    .onChange(of: fieldAmount) { oldValue, newValue in
                        let parsed = formatter.number(from: newValue)
                        let doubleValue = parsed != nil ? Double(truncating: parsed!) : 0
                        
                        if (doubleValue < 0 || doubleValue >= 1000) {
                            fieldAmount = oldValue
                            return
                        }
                        
                        if (doubleValue != pickerAmount) {
                            pickerAmount = doubleValue
                            amount = doubleValue
                        }
                    }
            } label: {
                Text("Amount")
            }
            Picker("", selection: $pickerAmount) {
                ForEach(isGrams ? [10, 25, 50, 75, 100] : [1, 2, 3, 4, 5], id: \.self) { number in
                    Text("\(number, specifier: "%.0f")").tag(number as Double)
                }
            }.pickerStyle(.segmented)
                .onChange(of: pickerAmount) {
                    let parsed = formatter.number(from: fieldAmount)
                    let fieldValue = parsed != nil ? Double(truncating: parsed!) : 0
                    if (pickerAmount != fieldValue) {
                        focusedField = nil
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.001) {
                            fieldAmount = formatter.string(from: NSNumber(value: pickerAmount)) ?? ""
                            focusedField = .field
                        }
                        amount = pickerAmount
                    }
                }
        }.onAppear {
            formatter.maximumFractionDigits = 2
            formatter.locale = .autoupdatingCurrent
            fieldAmount = amount != nil ? formatter.string(from: NSNumber(value: amount!)) ?? fieldAmount : fieldAmount
            pickerAmount = amount != nil ? amount! : pickerAmount
        }
    }
}
