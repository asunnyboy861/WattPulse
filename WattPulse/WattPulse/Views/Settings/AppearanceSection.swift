import SwiftUI

struct AppearanceSection: View {
    @AppStorage("APPEARANCE_MODE") private var appearanceMode: String = "system"

    var body: some View {
        Section {
            Picker("Appearance", selection: $appearanceMode) {
                Text("System").tag("system")
                Text("Light").tag("light")
                Text("Dark").tag("dark")
            }
            .pickerStyle(.segmented)
        } header: {
            Text("Appearance")
        } footer: {
            Text("Choose how WattPulse looks. Dark mode is optimized for OLED displays.")
                .font(.caption2)
        }
    }
}
