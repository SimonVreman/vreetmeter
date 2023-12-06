
import SwiftUI

struct CollapsableNumberPicker: View {
    @Binding var value: Int
    var range: [Int]
    
    @State private var pickerOpen = false
    
    var body: some View {
        LabeledContent {
            let text = "\(value.formatted(.number)) kcal"
            if pickerOpen { Text(text).foregroundStyle(.blue) } else { Text(text) }
        } label: {
            Text("Energy goal")
        }.onTapGesture { withAnimation {
            pickerOpen = !pickerOpen
        } }
        
        if pickerOpen {
            Picker("Energy goal", selection: $value) {
                ForEach(range, id: \.self) { Text("\($0)") }
            }.pickerStyle(.wheel)
        }
    }
}
