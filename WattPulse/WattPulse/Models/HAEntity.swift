import Foundation

enum EnergyCategory: String, Codable, CaseIterable {
    case solar
    case grid
    case battery
    case consumption
    case unknown

    var displayName: String {
        switch self {
        case .solar: return "Solar"
        case .grid: return "Grid"
        case .battery: return "Battery"
        case .consumption: return "Consumption"
        case .unknown: return "Other"
        }
    }

    var iconName: String {
        switch self {
        case .solar: return "sun.max.fill"
        case .grid: return "bolt.fill"
        case .battery: return "battery.100.bolt"
        case .consumption: return "house.fill"
        case .unknown: return "questionmark"
        }
    }

    var color: String {
        switch self {
        case .solar: return "SolarColor"
        case .grid: return "GridColor"
        case .battery: return "BatteryColor"
        case .consumption: return "ConsumptionColor"
        case .unknown: return "Secondary"
        }
    }
}

struct HAEntity: Identifiable, Codable, Hashable {
    let id: String
    let entityId: String
    let name: String
    let state: String
    let unit: String?
    let deviceClass: String?
    let category: EnergyCategory

    init(entityId: String, name: String, state: String, unit: String? = nil, deviceClass: String? = nil, category: EnergyCategory = .unknown) {
        self.id = entityId
        self.entityId = entityId
        self.name = name
        self.state = state
        self.unit = unit
        self.deviceClass = deviceClass
        self.category = category
    }

    var numericValue: Double? {
        Double(state.replacingOccurrences(of: "unavailable", with: "").trimmingCharacters(in: .whitespaces))
    }

    var isPowerEntity: Bool {
        unit?.lowercased() == "kw" || unit?.lowercased() == "w"
    }

    var isEnergyEntity: Bool {
        unit?.lowercased() == "kwh"
    }

    var displayValue: String {
        guard let value = numericValue else { return state }
        if isPowerEntity {
            return String(format: "%.2f kW", value)
        } else if isEnergyEntity {
            return String(format: "%.2f kWh", value)
        }
        return String(format: "%.1f", value)
    }
}
