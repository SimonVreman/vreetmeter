
import Foundation
import SwiftUI

struct DaySelector : View {
    @Binding var date: Date
    
    var body: some View {
        Button { } label: {
            BottomNavButton(icon: "calendar")
        }.background() {
            DatePicker("", selection: $date, displayedComponents: [.date])
                .frame(width: 0, height: 0)
                .clipped()
        }
    }
}
