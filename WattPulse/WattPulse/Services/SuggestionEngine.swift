import Foundation
import Combine

@MainActor
final class SuggestionEngine: ObservableObject {
    static let shared = SuggestionEngine()

    @Published private(set) var suggestions: [EnergySuggestion] = []
    @Published private(set) var dismissedSuggestions: Set<UUID> = []

    private var lastRefresh: Date = .distantPast
    private let refreshInterval: TimeInterval = TimeInterval(AppConfig.suggestionRefreshIntervalMinutes * 60)

    private init() {
        loadDismissedSuggestions()
    }

    func generateSuggestions(currentSolar: Double, currentConsumption: Double, currentBattery: Double, currentPrice: Double, averagePrice: Double) -> [EnergySuggestion] {
        guard Date().timeIntervalSince(lastRefresh) >= refreshInterval else {
            return suggestions
        }

        var newSuggestions: [EnergySuggestion] = []

        if currentSolar - currentConsumption > 1.0 && currentBattery > 90 {
            let saving = (currentSolar - currentConsumption) * currentPrice * 0.5
            newSuggestions.append(EnergySuggestion(
                type: .solarExcess,
                title: "Solar Surplus Available",
                description: "Run high-power appliances now to use excess solar energy. \(String(format: "%.1f", currentSolar - currentConsumption)) kW available.",
                potentialSaving: saving
            ))
        }

        if currentPrice < averagePrice * 0.7 && currentPrice > 0 {
            let saving = 2.0 * (averagePrice - currentPrice)
            newSuggestions.append(EnergySuggestion(
                type: .lowPrice,
                title: "Electricity Is Cheap Now",
                description: String(format: "Current rate $%.3f/kWh is %.0f%% below average. Good time to charge EV or run appliances.", currentPrice, (1 - currentPrice / averagePrice) * 100),
                potentialSaving: saving
            ))
        }

        if currentConsumption > 5.0 {
            newSuggestions.append(EnergySuggestion(
                type: .anomaly,
                title: "High Energy Usage Detected",
                description: String(format: "Current consumption %.1f kW is above normal. Check for unexpected loads.", currentConsumption),
                action: .showAlert
            ))
        }

        if currentBattery > 85 && currentPrice < averagePrice {
            let saving = (currentBattery / 100.0) * 5.0 * (averagePrice - currentPrice)
            newSuggestions.append(EnergySuggestion(
                type: .batteryOptimize,
                title: "Discharge Battery During Peak",
                description: String(format: "Battery at %.0f%%. Save money by discharging during peak hours.", currentBattery),
                potentialSaving: saving
            ))
        }

        let filtered = newSuggestions.filter { suggestion in
            !dismissedSuggestions.contains(suggestion.id)
        }

        suggestions = filtered
        lastRefresh = Date()
        return filtered
    }

    func dismiss(_ suggestion: EnergySuggestion) {
        dismissedSuggestions.insert(suggestion.id)
        suggestions.removeAll { $0.id == suggestion.id }
        saveDismissedSuggestions()
    }

    func clearDismissed() {
        dismissedSuggestions.removeAll()
        saveDismissedSuggestions()
    }

    private func loadDismissedSuggestions() {
        if let data = UserDefaults.standard.data(forKey: "DISMISSED_SUGGESTIONS"),
           let decoded = try? JSONDecoder().decode(Set<UUID>.self, from: data) {
            let cutoff = Date().addingTimeInterval(-86400)
            dismissedSuggestions = decoded.filter { _ in true }
            if dismissedSuggestions.contains(where: { _ in Date().timeIntervalSince(cutoff) > 86400 }) {
                dismissedSuggestions.removeAll()
            }
        }
    }

    private func saveDismissedSuggestions() {
        if let data = try? JSONEncoder().encode(dismissedSuggestions) {
            UserDefaults.standard.set(data, forKey: "DISMISSED_SUGGESTIONS")
        }
    }
}
