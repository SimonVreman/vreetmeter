
import SwiftUI

struct SettingsList: View {
    @Environment(SettingsState.self) var settings
    private var energyGoal: Binding<Int> { Binding(
        get: { settings.getValue(VMSettings.settingEnergyGoal.key) as? Int ?? 2000 },
        set: { settings.setValue(VMSettings.settingEnergyGoal.key, value: $0) }
    ) }
    
    var body: some View {
        List {
            Section("Nutrition") {
                Picker("Energy goal", selection: energyGoal) {
                    ForEach(0...100, id: \.self) { number in
                        let value = number * 50 + 1000
                        Text("\(value)").tag(value)
                    }
                }.pickerStyle(.wheel)
            }
        }.listStyle(.grouped)
    }
}
