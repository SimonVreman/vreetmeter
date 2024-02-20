
import SwiftUI

struct PreparationVariantPicker: View {
    @Binding var variant: Eetmeter.PreparationVariant?
    var variants: [Eetmeter.PreparationVariant]
    
    var body: some View {
        Picker("Preparation", selection: $variant) {
            ForEach(variants, id: \.id) { p in
                Text(p.name)
                    .lineLimit(1)
                    .truncationMode(.tail)
                    .tag(p as Eetmeter.PreparationVariant?)
            }
        }
    }
}
