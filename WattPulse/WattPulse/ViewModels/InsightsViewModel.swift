import Foundation
import SwiftUI
import Combine

@MainActor
final class InsightsViewModel: ObservableObject {
    @Published var suggestions: [EnergySuggestion] = []
    @Published var anomalies: [AnomalyEvent] = []
    @Published var weeklySummary: WeeklySummary?
    @Published var isLoading: Bool = false

    private let suggestionEngine = SuggestionEngine.shared
    private let anomalyDetector = AnomalyDetector.shared
    private let connectionManager = HAConnectionManager.shared
    private let costCalculator = CostCalculator.shared
    private var cancellables = Set<AnyCancellable>()

    init() {
        observeData()
    }

    private func observeData() {
        suggestionEngine.$suggestions
            .receive(on: RunLoop.main)
            .assign(to: &$suggestions)

        anomalyDetector.$recentAnomalies
            .receive(on: RunLoop.main)
            .assign(to: &$anomalies)
    }

    func refresh() async {
        isLoading = true
        let currentPrice = costCalculator.currentRate()
        let averagePrice = costCalculator.averageRate()
        let solar = connectionManager.entities.filter { $0.category == .solar }.compactMap { $0.numericValue }.reduce(0, +)
        let consumption = connectionManager.entities.filter { $0.category == .consumption }.compactMap { $0.numericValue }.reduce(0, +)
        let battery = connectionManager.entities.filter { $0.category == .battery }.compactMap { $0.numericValue }.reduce(0, +)

        suggestions = suggestionEngine.generateSuggestions(
            currentSolar: solar,
            currentConsumption: consumption,
            currentBattery: battery,
            currentPrice: currentPrice,
            averagePrice: averagePrice
        )

        computeWeeklySummary()
        isLoading = false
    }

    func dismissSuggestion(_ suggestion: EnergySuggestion) {
        suggestionEngine.dismiss(suggestion)
    }

    func markAnomalyAsNormal(_ event: AnomalyEvent) {
        let hour = Calendar.current.component(.hour, from: event.timestamp)
        anomalyDetector.markAsNormal(hour: hour)
    }

    private func computeWeeklySummary() {
        let calendar = Calendar.current
        let now = Date()
        let weekStart = calendar.date(byAdding: .day, value: -7, to: now) ?? now

        weeklySummary = WeeklySummary(
            weekStart: weekStart,
            weekEnd: now,
            totalSolarKWh: 0,
            totalConsumptionKWh: 0,
            totalSavings: 0,
            co2OffsetKg: 0,
            bestDay: nil,
            worstDay: nil
        )
    }
}

struct WeeklySummary: Identifiable {
    let id = UUID()
    let weekStart: Date
    let weekEnd: Date
    let totalSolarKWh: Double
    let totalConsumptionKWh: Double
    let totalSavings: Double
    let co2OffsetKg: Double
    let bestDay: Date?
    let worstDay: Date?

    var formattedSolar: String { String(format: "%.1f kWh", totalSolarKWh) }
    var formattedConsumption: String { String(format: "%.1f kWh", totalConsumptionKWh) }
    var formattedSavings: String { String(format: "$%.2f", totalSavings) }
    var formattedCO2: String { String(format: "%.1f kg", co2OffsetKg) }
}
