import Foundation
import SwiftData

@Model
final class DailySummary {
    @Attribute(.unique) var id: UUID
    var date: Date
    var solarProductionKWh: Double
    var gridImportKWh: Double
    var gridExportKWh: Double
    var batteryDischargeKWh: Double
    var batteryChargeKWh: Double
    var totalConsumptionKWh: Double
    var totalCost: Double
    var solarRevenue: Double
    var co2OffsetKg: Double

    init(date: Date, solarProductionKWh: Double = 0, gridImportKWh: Double = 0, gridExportKWh: Double = 0, batteryDischargeKWh: Double = 0, batteryChargeKWh: Double = 0, totalConsumptionKWh: Double = 0, totalCost: Double = 0, solarRevenue: Double = 0, co2OffsetKg: Double = 0) {
        self.id = UUID()
        self.date = date
        self.solarProductionKWh = solarProductionKWh
        self.gridImportKWh = gridImportKWh
        self.gridExportKWh = gridExportKWh
        self.batteryDischargeKWh = batteryDischargeKWh
        self.batteryChargeKWh = batteryChargeKWh
        self.totalConsumptionKWh = totalConsumptionKWh
        self.totalCost = totalCost
        self.solarRevenue = solarRevenue
        self.co2OffsetKg = co2OffsetKg
    }
}
