
import SwiftUI

let VMSettingsPrefix = "vreetmeter.settings."

enum VMSettings: String, CaseIterable {
    case energyGoal = "energyGoal"
    case weightGoal = "weightGoal"
    case adjustEnergyGoal = "adjustEnergyGoal"
    case energyAdjustmentSize = "energyAdjustmentSize"
    
    var key: String { VMSettingsPrefix + self.rawValue }
}

@Observable class SettingsState {
    private var values: [String:Any] = [:]
    
    init() {
        for setting in VMSettings.allCases {
            self.values[setting.key] = self.loadValue(setting.key)
        }
    }
    
    private func loadValue(_ key: String) -> Any? {
        return UserDefaults.standard.object(forKey: key)
    }
    
    private func saveValue(_ key: String, value: Any?) {
        UserDefaults.standard.set(value, forKey: key)
        self.values[key] = value
    }
    
    func getValue(_ key: String) -> Any? {
        return self.values[key]
    }
    
    func setValue(_ key: String, value: Any?) {
        self.saveValue(key, value: value)
    }
}
