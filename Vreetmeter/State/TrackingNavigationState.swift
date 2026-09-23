
import SwiftUI

@Observable class TrackingNavigationState {
    var selectionPath = NavigationPath()

    var date: Date = .now.startOfDay
    var meal: Meal?
    var consumptionSubmit: Bool = false
    var onDailyView: Bool { self.selectionPath.isEmpty }
    
    func append(_ v: any Hashable) {
        self.selectionPath.append(v)
    }
    
    func removeLast() {
        self.selectionPath.removeLast()
    }
    
    func productSaved() {
        if (self.selectionPath.count <= 1) {
            self.consumptionSubmit.toggle()
        } else {
            self.removeLast()
        }
    }
}
