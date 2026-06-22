import Foundation
import SwiftData
import Combine

@MainActor
final class AnomalyDetector: ObservableObject {
    static let shared = AnomalyDetector()

    @Published private(set) var recentAnomalies: [AnomalyEvent] = []

    private var usageProfile: [Int: Double] = [:]
    private let notificationScheduler = NotificationScheduler.shared

    private init() {
        loadUsageProfile()
    }

    func check(currentConsumption: Double, hour: Int = Calendar.current.component(.hour, from: Date())) -> AnomalyEvent? {
        guard let normal = usageProfile[hour], normal > 0 else { return nil }

        let threshold = normal * AppConfig.anomalyThresholdMultiplier
        if currentConsumption > threshold {
            let event = AnomalyEvent(
                timestamp: .now,
                power: currentConsumption,
                normalPower: normal,
                ratio: currentConsumption / normal
            )
            recentAnomalies.insert(event, at: 0)
            if recentAnomalies.count > 50 {
                recentAnomalies.removeLast()
            }
            Task { await notificationScheduler.scheduleAnomalyAlert(event) }
            return event
        }
        return nil
    }

    func markAsNormal(hour: Int) {
        usageProfile[hour] = (usageProfile[hour] ?? 0) * 1.1
        saveUsageProfile()
    }

    func updateUsageProfile(hour: Int, consumption: Double) {
        let current = usageProfile[hour] ?? consumption
        let smoothed = current * 0.9 + consumption * 0.1
        usageProfile[hour] = smoothed
        saveUsageProfile()
    }

    private func loadUsageProfile() {
        if let data = UserDefaults.standard.data(forKey: "USAGE_PROFILE"),
           let decoded = try? JSONDecoder().decode([Int: Double].self, from: data) {
            usageProfile = decoded
        } else {
            for hour in 0..<24 {
                usageProfile[hour] = 1.0
            }
        }
    }

    private func saveUsageProfile() {
        if let data = try? JSONEncoder().encode(usageProfile) {
            UserDefaults.standard.set(data, forKey: "USAGE_PROFILE")
        }
    }
}

struct AnomalyEvent: Identifiable, Codable {
    let id: UUID
    let timestamp: Date
    let power: Double
    let normalPower: Double
    let ratio: Double

    init(timestamp: Date, power: Double, normalPower: Double, ratio: Double) {
        self.id = UUID()
        self.timestamp = timestamp
        self.power = power
        self.normalPower = normalPower
        self.ratio = ratio
    }

    var formattedPower: String {
        String(format: "%.1f kW", power)
    }

    var formattedTime: String {
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        formatter.timeStyle = .short
        return formatter.string(from: timestamp)
    }
}
