
import Foundation
import SwiftData

@Model
class IntensityTechnique {
    @Attribute(.unique) var name: String
    var decription: String
    
    init(name: String, decription: String) {
        self.name = name
        self.decription = decription
    }
}
