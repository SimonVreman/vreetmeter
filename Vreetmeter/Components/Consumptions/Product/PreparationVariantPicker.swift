
import SwiftUI

struct PreparationVariantPicker: View {
    @Binding var variant: Eetmeter.PreparationVariant?
    var variants: [Eetmeter.PreparationVariant]
    
    var body: some View {
        if (variants.count > 1 && variant != nil) {
            Picker("Preparation", selection: $variant) {
                ForEach(variants, id: \.id) { p in
                    Text(p.name)
                        .lineLimit(1)
                        .truncationMode(.tail)
                        .tag(p as Eetmeter.PreparationVariant?)
                }
            }.if(variants.count <= 3) { v in
                v.pickerStyle(.segmented)
            }.if(variants.count > 3) { v in
                v.pickerStyle(.navigationLink)
                    .background(Color(UIColor.systemGroupedBackground))
            }
        } else {
            HStack {
                Text("Preparation")
                Spacer()
                Text(variant?.name ?? "").foregroundStyle(.secondary)
            }
        }
    }
}
