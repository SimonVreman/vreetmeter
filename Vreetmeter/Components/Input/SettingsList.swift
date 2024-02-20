
import SwiftUI

struct SettingsList: View {
    @Environment(SettingsState.self) var settings
    @Environment(ProductState.self) var products
    @Environment(EetmeterAPI.self) var eetmeter
    
    @State private var refreshingUserData: Bool = false
    
    private var energyGoal: Binding<Int> { Binding(
        get: { settings.getValue(VMSettings.energyGoal.key) as? Int ?? 2000 },
        set: { settings.setValue(VMSettings.energyGoal.key, value: $0) }
    ) }
    
    private var adjustEnergyGoal: Binding<Bool> { Binding(
        get: { settings.getValue(VMSettings.adjustEnergyGoal.key) as? Bool ?? false },
        set: { settings.setValue(VMSettings.adjustEnergyGoal.key, value: $0) }
    ) }
    
    private var weightGoal: Binding<WeightGoal> { Binding(
        get: {
            let storedValue = settings.getValue(VMSettings.weightGoal.key) as? Int
            if storedValue == nil { return .maintain }
            return WeightGoal(rawValue: storedValue!) ?? .maintain
        },
        set: { settings.setValue(VMSettings.weightGoal.key, value: $0.rawValue) }
    ) }
    
    private var energyAdjustmentSize: Binding<EnergyAdjustmentSize> { Binding(
        get: {
            let storedValue = settings.getValue(VMSettings.energyAdjustmentSize.key) as? Int
            if storedValue == nil { return .normal }
            return EnergyAdjustmentSize(rawValue: storedValue!) ?? .normal
        },
        set: { settings.setValue(VMSettings.energyAdjustmentSize.key, value: $0.rawValue) }
    ) }
    
    var body: some View {
        List {
            Section {
                let range = stride(from: 1000, to: 5001, by: 50).map { $0 }
                CollapsableNumberPicker(value: energyGoal, range: range)
                
                Toggle("Adjust automatically", isOn: adjustEnergyGoal)
                
                if adjustEnergyGoal.wrappedValue {
                    Picker("Goal", selection: weightGoal) {
                        Text("Lose").tag(WeightGoal.lose)
                        Text("Maintain").tag(WeightGoal.maintain)
                        Text("Gain").tag(WeightGoal.gain)
                    }.pickerStyle(.navigationLink)
                    
                    Picker("Adjustment size", selection: energyAdjustmentSize) {
                        Text("Small").tag(EnergyAdjustmentSize.small)
                        Text("Normal").tag(EnergyAdjustmentSize.normal)
                        Text("Large").tag(EnergyAdjustmentSize.large)
                    }.pickerStyle(.navigationLink)
                }
            } header: { Text("Nutrition") } footer: {
                Text("When automatic adjustment is on, your energy goal will be automatically updated based on your recent weight changes.")
            }
            
            Section("Eetmeter") {
                Button("Refresh user data") {
                    Task {
                        if (refreshingUserData) { return }
                        refreshingUserData = true
                        try await eetmeter.fetchFavorites()
                        try await products.fetchCombinedProducts()
                        refreshingUserData = false
                    }
                }.disabled(refreshingUserData)
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
