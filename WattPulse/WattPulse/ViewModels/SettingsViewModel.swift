import Foundation
import SwiftUI
import SwiftData
import Combine

@MainActor
final class SettingsViewModel: ObservableObject {
    @Published var ratePlan: RatePlan = .defaultPlan
    @Published var flatRate: String = "0.15"
    @Published var peakRate: String = "0.30"
    @Published var shoulderRate: String = "0.20"
    @Published var offPeakRate: String = "0.10"
    @Published var peakStartHour: String = "16"
    @Published var peakEndHour: String = "21"
    @Published var notificationsEnabled: Bool = false
    @Published var anomalyAlertsEnabled: Bool = true
    @Published var lowPriceAlertsEnabled: Bool = true
    @Published var suggestionAlertsEnabled: Bool = true
    @Published var csvExportRange: TimeRange = .month
    @Published var exportError: String?
    @Published var exportSuccess: Bool = false

    private let costCalculator = CostCalculator.shared
    private let csvExporter = CSVExporter.shared
    private let notificationScheduler = NotificationScheduler.shared
    private var modelContext: ModelContext?

    init() {
        ratePlan = costCalculator.loadRatePlan()
        loadPlanFields()
        loadNotificationSettings()
    }

    func setModelContext(_ context: ModelContext) {
        self.modelContext = context
    }

    private func loadPlanFields() {
        switch ratePlan {
        case .flat(let rate):
            flatRate = String(format: "%.3f", rate)
        case .timeOfUse(let peak, let shoulder, let offPeak, let peakStart, let peakEnd):
            peakRate = String(format: "%.3f", peak)
            shoulderRate = String(format: "%.3f", shoulder)
            offPeakRate = String(format: "%.3f", offPeak)
            peakStartHour = String(peakStart)
            peakEndHour = String(peakEnd)
        case .realTime:
            break
        }
    }

    private func loadNotificationSettings() {
        notificationsEnabled = UserDefaults.standard.bool(forKey: "NOTIFICATIONS_ENABLED")
        anomalyAlertsEnabled = UserDefaults.standard.object(forKey: "ANOMALY_ALERTS") as? Bool ?? true
        lowPriceAlertsEnabled = UserDefaults.standard.object(forKey: "LOW_PRICE_ALERTS") as? Bool ?? true
        suggestionAlertsEnabled = UserDefaults.standard.object(forKey: "SUGGESTION_ALERTS") as? Bool ?? true
    }

    func saveRatePlan() {
        let plan: RatePlan
        switch ratePlan {
        case .flat:
            plan = .flat(rate: Double(flatRate) ?? 0.15)
        case .timeOfUse:
            plan = .timeOfUse(
                peak: Double(peakRate) ?? 0.30,
                shoulder: Double(shoulderRate) ?? 0.20,
                offPeak: Double(offPeakRate) ?? 0.10,
                peakStartHour: Int(peakStartHour) ?? 16,
                peakEndHour: Int(peakEndHour) ?? 21
            )
        case .realTime:
            plan = ratePlan
        }
        costCalculator.saveRatePlan(plan)
        ratePlan = plan
        HapticManager.success()
    }

    func toggleNotifications(_ enabled: Bool) {
        notificationsEnabled = enabled
        UserDefaults.standard.set(enabled, forKey: "NOTIFICATIONS_ENABLED")
        if enabled {
            Task {
                let granted = await notificationScheduler.requestAuthorization()
                if !granted {
                    notificationsEnabled = false
                    UserDefaults.standard.set(false, forKey: "NOTIFICATIONS_ENABLED")
                }
            }
        }
    }

    func toggleAnomalyAlerts(_ enabled: Bool) {
        anomalyAlertsEnabled = enabled
        UserDefaults.standard.set(enabled, forKey: "ANOMALY_ALERTS")
    }

    func toggleLowPriceAlerts(_ enabled: Bool) {
        lowPriceAlertsEnabled = enabled
        UserDefaults.standard.set(enabled, forKey: "LOW_PRICE_ALERTS")
    }

    func toggleSuggestionAlerts(_ enabled: Bool) {
        suggestionAlertsEnabled = enabled
        UserDefaults.standard.set(enabled, forKey: "SUGGESTION_ALERTS")
    }

    func exportCSV() {
        guard let context = modelContext else { return }
        let range = csvExportRange.dateInterval
        let descriptor = FetchDescriptor<DailySummary>(
            predicate: #Predicate { $0.date >= range.start && $0.date <= range.end },
            sortBy: [SortDescriptor(\.date)]
        )
        do {
            let summaries = try context.fetch(descriptor)
            if let url = csvExporter.export(summaries: summaries) {
                csvExporter.shareCSV(at: url)
                exportSuccess = true
                exportError = nil
            } else {
                exportError = "Failed to create CSV file."
            }
        } catch {
            exportError = "Failed to fetch data: \(error.localizedDescription)"
        }
    }

    var appVersion: String {
        let version = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.0"
        let build = Bundle.main.infoDictionary?["CFBundleVersion"] as? String ?? "1"
        return "Version \(version) (\(build))"
    }
}
