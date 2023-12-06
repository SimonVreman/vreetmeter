
import SwiftUI

class NavigationState: ObservableObject {
    @Published var selectionPath: [AnyHashable] = []
    var date: Date = .now.startOfDay
    
    func lastOfType<T>() -> T? {
        let item = self.selectionPath.last(where: { item in
            return item as? T != nil
        })
        return item as? T
    }
    
    func reset() {
        self.selectionPath.removeLast(self.selectionPath.count)
    }
}
