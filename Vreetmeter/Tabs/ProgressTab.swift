
import SwiftUI

struct ProgressTab: View {
    var body: some View {
        NavigationView {
            HStack {
                VStack {
                    WeightCard()
                }.padding()
            }.navigationTitle("Progress")
        }.background(Color(UIColor.systemGroupedBackground))
    }
}
