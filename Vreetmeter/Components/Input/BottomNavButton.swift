
import SwiftUI

struct BottomNavButton: View {
    let icon: String
    
    var body: some View {
        Button { } label: {
            Image(systemName: icon).font(.system(.headline, weight: .light))
        }
    }
}
