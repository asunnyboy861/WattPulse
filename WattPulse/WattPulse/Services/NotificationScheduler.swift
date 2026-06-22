import Foundation
import UserNotifications

@MainActor
final class NotificationScheduler {
    static let shared = NotificationScheduler()

    private init() {}

    func requestAuthorization() async -> Bool {
        do {
            return try await UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound])
        } catch {
            return false
        }
    }

    func scheduleAnomalyAlert(_ event: AnomalyEvent) async {
        let granted = await requestAuthorization()
        guard granted else { return }

        let content = UNMutableNotificationContent()
        content.title = "Unusual Energy Spike"
        content.body = String(format: "%.1f kW detected at %@. This is %.1fx your normal usage.", event.power, event.formattedTime, event.ratio)
        content.sound = .default
        content.categoryIdentifier = "ANOMALY"

        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 1, repeats: false)
        let request = UNNotificationRequest(identifier: event.id.uuidString, content: content, trigger: trigger)
        try? await UNUserNotificationCenter.current().add(request)
    }

    func scheduleSuggestionReminder(_ suggestion: EnergySuggestion, at date: Date) async {
        let granted = await requestAuthorization()
        guard granted else { return }

        let content = UNMutableNotificationContent()
        content.title = suggestion.title
        content.body = suggestion.description
        content.sound = .default

        let components = Calendar.current.dateComponents([.year, .month, .day, .hour, .minute], from: date)
        let trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: false)
        let request = UNNotificationRequest(identifier: suggestion.id.uuidString, content: content, trigger: trigger)
        try? await UNUserNotificationCenter.current().add(request)
    }

    func scheduleLowPriceAlert(at date: Date, price: Double) async {
        let granted = await requestAuthorization()
        guard granted else { return }

        let content = UNMutableNotificationContent()
        content.title = "Low Electricity Price"
        content.body = String(format: "Electricity is $%.3f/kWh now. Good time to run appliances.", price)
        content.sound = .default

        let components = Calendar.current.dateComponents([.year, .month, .day, .hour, .minute], from: date)
        let trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: false)
        let request = UNNotificationRequest(identifier: "low-price-\(date.timeIntervalSince1970)", content: content, trigger: trigger)
        try? await UNUserNotificationCenter.current().add(request)
    }
}
