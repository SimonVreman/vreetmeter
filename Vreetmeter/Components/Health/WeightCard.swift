
import SwiftUI
import Charts

struct WeightCard: View {
    var data: [NumericalDatePoint]
    
    var body: some View {
        GroupBox {
            VStack(alignment: .leading) {
                HStack(alignment: .bottom) {
                    let mostRecent = self.data.last?.value
                    Text(mostRecent != nil ? "\(mostRecent!, specifier: "%.1f")" : "--.-")
                        .font(.largeTitle).fontDesign(.rounded).fontWeight(.semibold)
                    + Text("kg").font(.headline).foregroundStyle(.primary.secondary)
                    
                    Text("last 30 days").font(.headline).foregroundStyle(.primary.secondary)
                }
                
                WeightChart(data: data)
            }
        }.cardBackgroundAndShadow()
            .frame(height: 300)
    }
}
