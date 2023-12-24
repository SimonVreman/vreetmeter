
import SwiftUI

struct QuickProductSearch: View {
    var body: some View {
        HStack(spacing: 16) {
            HStack(spacing: 4) {
                Image(systemName: "magnifyingglass")
                Text("Search")
                Spacer()
            }.padding(8).background {
                RoundedRectangle(cornerRadius: 8).fill(.gray.quinary)
            }.foregroundStyle(.secondary)
            Button {} label: { Image(systemName: "questionmark.square").scaleEffect(1.3) }
            Button {} label: { Image(systemName: "barcode.viewfinder").scaleEffect(1.3) }
        }
    }
}

#Preview {
    VStack {
        NavigationView {
            VStack {
                QuickProductSearch().padding(.horizontal)
                List {
                    Text("row")
                    Text("row")
                }.searchable(text: .constant(""))
            }
        }
    }
}
