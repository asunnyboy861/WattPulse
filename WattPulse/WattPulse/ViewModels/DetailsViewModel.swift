import Foundation
import SwiftUI
import SwiftData
import Combine

@MainActor
final class DetailsViewModel: ObservableObject {
    @Published var selectedEntity: HAEntity?
    @Published var hourlyData: [EnergyDataPoint] = []
    @Published var monthlyData: [DailySummary] = []
    @Published var totalSolarKWh: Double = 0
    @Published var totalGridImportKWh: Double = 0
    @Published var totalGridExportKWh: Double = 0
    @Published var totalConsumptionKWh: Double = 0
    @Published var totalCost: Double = 0
    @Published var totalCO2Offset: Double = 0
    @Published var totalSavings: Double = 0

    private let discoveryManager = EnergyDiscoveryManager.shared
    private let costCalculator = CostCalculator.shared
    private var modelContext: ModelContext?

    func setModelContext(_ context: ModelContext) {
        self.modelContext = context
        Task { await loadData() }
    }

    func loadData() async {
        guard let context = modelContext else { return }
        let calendar = Calendar.current
        let yearAgo = calendar.date(byAdding: .year, value: -1, to: Date()) ?? Date()
        let descriptor = FetchDescriptor<DailySummary>(
            predicate: #Predicate { $0.date >= yearAgo },
            sortBy: [SortDescriptor(\.date)]
        )
        do {
            let summaries = try context.fetch(descriptor)
            monthlyData = summaries
            totalSolarKWh = summaries.reduce(0) { $0 + $1.solarProductionKWh }
            totalGridImportKWh = summaries.reduce(0) { $0 + $1.gridImportKWh }
            totalGridExportKWh = summaries.reduce(0) { $0 + $1.gridExportKWh }
            totalConsumptionKWh = summaries.reduce(0) { $0 + $1.totalConsumptionKWh }
            totalCost = summaries.reduce(0) { $0 + $1.totalCost }
            totalCO2Offset = summaries.reduce(0) { $0 + $1.co2OffsetKg }
            totalSavings = summaries.reduce(0) { $0 + max(0, $1.solarRevenue - $1.totalCost) }
        } catch {
            monthlyData = []
        }

        await loadHourlyData()
    }

    func loadHourlyData() async {
        guard let context = modelContext else { return }
        let today = TimeRange.today.dateInterval
        let descriptor = FetchDescriptor<EnergyRecord>(
            predicate: #Predicate { $0.timestamp >= today.start && $0.timestamp <= today.end },
            sortBy: [SortDescriptor(\.timestamp)]
        )
        do {
            let records = try context.fetch(descriptor)
            let grouped = Dictionary(grouping: records) { record in
                Calendar.current.component(.hour, from: record.timestamp)
            }
            hourlyData = grouped.compactMap { (hour, hourRecords) -> EnergyDataPoint? in
                let solar = hourRecords.filter { $0.category == "solar" }.reduce(0.0) { $0 + $1.value }
                let grid = hourRecords.filter { $0.category == "grid" }.reduce(0.0) { $0 + $1.value }
                let battery = hourRecords.filter { $0.category == "battery" }.reduce(0.0) { $0 + $1.value }
                let consumption = hourRecords.filter { $0.category == "consumption" }.reduce(0.0) { $0 + $1.value }
                let date = Calendar.current.date(bySettingHour: hour, minute: 0, second: 0, of: Date()) ?? Date()
                return EnergyDataPoint(
                    timestamp: date,
                    solarProduction: solar,
                    gridImport: max(0, grid),
                    gridExport: max(0, -grid),
                    batteryDischarge: max(0, battery),
                    batteryCharge: max(0, -battery),
                    totalConsumption: consumption,
                    costPerKWh: self.costCalculator.currentRate()
                )
            }.sorted { $0.timestamp < $1.timestamp }
        } catch {
            hourlyData = []
        }
    }

    var solarEntities: [HAEntity] { discoveryManager.solarEntities }
    var gridEntities: [HAEntity] { discoveryManager.gridEntities }
    var batteryEntities: [HAEntity] { discoveryManager.batteryEntities }
    var consumptionEntities: [HAEntity] { discoveryManager.consumptionEntities }

    var formattedTotalSolar: String { String(format: "%.1f kWh", totalSolarKWh) }
    var formattedTotalGridImport: String { String(format: "%.1f kWh", totalGridImportKWh) }
    var formattedTotalGridExport: String { String(format: "%.1f kWh", totalGridExportKWh) }
    var formattedTotalConsumption: String { String(format: "%.1f kWh", totalConsumptionKWh) }
    var formattedTotalCost: String { String(format: "$%.2f", totalCost) }
    var formattedTotalCO2: String {
        if totalCO2Offset >= 1000 {
            return String(format: "%.1f t", totalCO2Offset / 1000)
        }
        return String(format: "%.1f kg", totalCO2Offset)
    }
    var formattedTotalSavings: String { String(format: "$%.2f", totalSavings) }
}

extension DailySummary {
    var savings: Double {
        max(0, solarRevenue - totalCost)
    }
}
