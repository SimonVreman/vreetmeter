
import Foundation
import SwiftData

@Model
class Exercise {
    @Attribute(.unique) var name: String
    var video: String?
    var instruction: String?
    
    init(name: String) {
        self.name = name
    }
}
