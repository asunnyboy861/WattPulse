import Foundation

enum RatePlan: Codable, Equatable, Hashable {
    case flat(rate: Double)
    case timeOfUse(peak: Double, shoulder: Double, offPeak: Double, peakStartHour: Int, peakEndHour: Int)
    case realTime(prices: [Date: Double])

    var displayName: String {
        switch self {
        case .flat: return "Flat Rate"
        case .timeOfUse: return "Time of Use"
        case .realTime: return "Real-Time Pricing"
        }
    }

    var iconName: String {
        switch self {
        case .flat: return "equal.square"
        case .timeOfUse: return "clock.fill"
        case .realTime: return "chart.line.uptrend.xyaxis"
        }
    }

    func rateForHour(_ hour: Int) -> Double {
        switch self {
        case .flat(let rate):
            return rate
        case .timeOfUse(let peak, let shoulder, let offPeak, let peakStart, let peakEnd):
            if hour >= peakStart && hour < peakEnd {
                return peak
            }
            if hour >= 6 && hour < 9 || hour >= 17 && hour < 21 {
                return shoulder
            }
            return offPeak
        case .realTime(let prices):
            let calendar = Calendar.current
            let now = Date()
            let components = calendar.dateComponents([.year, .month, .day, .hour], from: now)
            let hourDate = calendar.date(from: components) ?? now
            return prices[hourDate] ?? 0.12
        }
    }

    var description: String {
        switch self {
        case .flat(let rate):
            return String(format: "$%.3f/kWh flat", rate)
        case .timeOfUse(let peak, _, let offPeak, let peakStart, let peakEnd):
            return String(format: "Peak $%.3f (%d:00-%d:00), Off-peak $%.3f", peak, peakStart, peakEnd, offPeak)
        case .realTime:
            return "Real-time market price"
        }
    }

    static var defaultPlan: RatePlan {
        .flat(rate: 0.15)
    }
}
