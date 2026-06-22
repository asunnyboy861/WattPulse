import Foundation

enum TimeRange: String, CaseIterable, Identifiable {
    case today
    case week
    case month
    case year

    var id: String { rawValue }

    var displayName: String {
        switch self {
        case .today: return "Today"
        case .week: return "Week"
        case .month: return "Month"
        case .year: return "Year"
        }
    }

    var dateInterval: DateInterval {
        let calendar = Calendar.current
        let now = Date()
        switch self {
        case .today:
            let start = calendar.startOfDay(for: now)
            let end = calendar.date(byAdding: .day, value: 1, to: start) ?? now
            return DateInterval(start: start, end: end)
        case .week:
            let start = calendar.date(byAdding: .day, value: -6, to: calendar.startOfDay(for: now)) ?? now
            return DateInterval(start: start, end: now)
        case .month:
            let start = calendar.date(byAdding: .day, value: -29, to: calendar.startOfDay(for: now)) ?? now
            return DateInterval(start: start, end: now)
        case .year:
            let start = calendar.date(byAdding: .month, value: -11, to: calendar.startOfDay(for: now)) ?? now
            return DateInterval(start: start, end: now)
        }
    }

    var chartStride: Calendar.Component {
        switch self {
        case .today: return .hour
        case .week: return .day
        case .month: return .day
        case .year: return .month
        }
    }

    var dateFormat: String {
        switch self {
        case .today: return "HH:mm"
        case .week: return "EEE"
        case .month: return "d"
        case .year: return "MMM"
        }
    }
}
