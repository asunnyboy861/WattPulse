import Foundation

enum SuggestionType: String, Codable {
    case solarExcess
    case lowPrice
    case anomaly
    case batteryOptimize

    var iconName: String {
        switch self {
        case .solarExcess: return "sun.max.fill"
        case .lowPrice: return "tag.fill"
        case .anomaly: return "exclamationmark.triangle.fill"
        case .batteryOptimize: return "battery.100.bolt"
        }
    }

    var color: String {
        switch self {
        case .solarExcess: return "SolarColor"
        case .lowPrice: return "GridColor"
        case .anomaly: return "AnomalyColor"
        case .batteryOptimize: return "BatteryColor"
        }
    }
}

enum SuggestionAction: String, Codable {
    case setReminder
    case dismiss
    case showAlert
    case none
}

struct EnergySuggestion: Identifiable, Codable {
    let id: UUID
    let type: SuggestionType
    let title: String
    let description: String
    let potentialSaving: Double
    let action: SuggestionAction
    let createdAt: Date
    var isDismissed: Bool

    init(type: SuggestionType, title: String, description: String, potentialSaving: Double = 0, action: SuggestionAction = .setReminder) {
        self.id = UUID()
        self.type = type
        self.title = title
        self.description = description
        self.potentialSaving = potentialSaving
        self.action = action
        self.createdAt = .now
        self.isDismissed = false
    }

    var formattedSaving: String {
        potentialSaving > 0 ? String(format: "Save $%.2f", potentialSaving) : ""
    }
}
