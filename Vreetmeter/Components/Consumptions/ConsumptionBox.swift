
import Foundation
import SwiftUI

struct ConsumptionBox: View {
    @Environment(\.colorScheme) var colorScheme
    
    var label: String
    var icon: String
    var color: Color
    var consumptions: [Consumption]
    var destination: Meal
    
    var body: some View {
        NavigationLink(value: destination) {
            GroupBox(label: HStack {
                Label(label, systemImage: icon).foregroundColor(color)
                Spacer()
                Image(systemName: "chevron.right").foregroundColor(Color(.systemGray4)).imageScale(.small)
            }) {
                if (consumptions.isEmpty) {
                    HStack(content: {
                        Text("No consumptions yet").font(.system(size: 14, weight: .semibold, design: .rounded)).foregroundColor(.secondary)
                        Spacer()
                    }).padding(.top, 2)
                } else {
                    ConsumptionSummary(consumptions: consumptions)
                        .fixedSize(horizontal: false, vertical: true)
                }
            }.backgroundStyle(.background.secondary)
                .compositingGroup()
                .shadow(color: .black.opacity(0.1), radius: 10)
        }.listRowSeparator(.hidden)
            .listRowInsets(.init())
            .listRowBackground(Color.clear)
    }
}
