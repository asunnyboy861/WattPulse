import Foundation

struct EnergyDataPoint: Identifiable, Codable, Hashable {
    let id: UUID
    let timestamp: Date
    var solarProduction: Double
    var gridImport: Double
    var gridExport: Double
    var batteryDischarge: Double
    var batteryCharge: Double
    var totalConsumption: Double
    var costPerKWh: Double

    init(timestamp: Date, solarProduction: Double = 0, gridImport: Double = 0, gridExport: Double = 0, batteryDischarge: Double = 0, batteryCharge: Double = 0, totalConsumption: Double = 0, costPerKWh: Double = 0) {
        self.id = UUID()
        self.timestamp = timestamp
        self.solarProduction = solarProduction
        self.gridImport = gridImport
        self.gridExport = gridExport
        self.batteryDischarge = batteryDischarge
        self.batteryCharge = batteryCharge
        self.totalConsumption = totalConsumption
        self.costPerKWh = costPerKWh
    }

    var netGrid: Double {
        gridImport - gridExport
    }

    var isSolarSurplus: Bool {
        solarProduction > totalConsumption
    }
}
