
import SwiftUI

struct ProductUnitPicker: View {
    @Binding var unit: Eetmeter.ProductUnit?
    var units: [Eetmeter.ProductUnit]
    
    var body: some View {
        Picker("Unit", selection: $unit) {
            ForEach(units) { u in
                Text(u.displayName)
                    .lineLimit(1)
                    .truncationMode(.tail)
                    .tag(u as Eetmeter.ProductUnit?)
            }
        }
    }
}
