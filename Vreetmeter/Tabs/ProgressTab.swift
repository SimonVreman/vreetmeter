
import SwiftUI

struct ProgressTab: View {
    var body: some View {
        NavigationView {
            VStack {
                WeightChart()
            }.padding()
        }.navigationTitle("Progress")
            .navigationBarTitleDisplayMode(.large)
            .background(Color(UIColor.systemGroupedBackground))
    }
}

#Preview {
    ProgressTab()
}
