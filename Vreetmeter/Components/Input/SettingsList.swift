
import SwiftUI

struct SettingsList: View {
    @Environment(SettingsState.self) var settings
    @Environment(EetmeterAPI.self) var eetmeter
    
    private var energyGoal: Binding<Int> { Binding(
        get: { settings.getValue(VMSettings.settingEnergyGoal.key) as? Int ?? 2000 },
        set: { settings.setValue(VMSettings.settingEnergyGoal.key, value: $0) }
    ) }
    
    var body: some View {
        List {
            Section("Nutrition") {
                let range = stride(from: 1000, to: 5001, by: 50).map { $0 }
                CollapsableNumberPicker(value: energyGoal, range: range)
            }
            
            Section("Eetmeter") {
                Button("Logout") {
                    eetmeter.logout()
                }.foregroundStyle(.red)
            }
        }.listStyle(.grouped)
    }
}

#Preview {
    SettingsList().environment(SettingsState()).environment(EetmeterAPI())
}
