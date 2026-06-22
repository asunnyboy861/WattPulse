import SwiftUI

struct NotificationsSection: View {
    @ObservedObject var viewModel: SettingsViewModel

    var body: some View {
        Section {
            Toggle("Enable Notifications", isOn: Binding(
                get: { viewModel.notificationsEnabled },
                set: { viewModel.toggleNotifications($0) }
            ))

            if viewModel.notificationsEnabled {
                Toggle("Anomaly Alerts", isOn: Binding(
                    get: { viewModel.anomalyAlertsEnabled },
                    set: { viewModel.toggleAnomalyAlerts($0) }
                ))
                Toggle("Low Price Alerts", isOn: Binding(
                    get: { viewModel.lowPriceAlertsEnabled },
                    set: { viewModel.toggleLowPriceAlerts($0) }
                ))
                Toggle("Suggestion Alerts", isOn: Binding(
                    get: { viewModel.suggestionAlertsEnabled },
                    set: { viewModel.toggleSuggestionAlerts($0) }
                ))
            }
        } header: {
            Text("Notifications")
        } footer: {
            Text("Receive alerts for unusual energy usage, low electricity prices, and smart suggestions.")
                .font(.caption2)
        }
    }
}
