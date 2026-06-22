import Foundation
import SwiftUI
import SwiftData
import Combine

@MainActor
final class DashboardViewModel: ObservableObject {
    @Published var currentSolar: Double = 0
    @Published var currentGrid: Double = 0
    @Published var currentBattery: Double = 0
    @Published var currentConsumption: Double = 0
    @Published var batteryPercentage: Double = 0
    @Published var selectedTimeRange: TimeRange = .today
    @Published var chartData: [EnergyDataPoint] = []
    @Published var costResult: CostResult?
    @Published var suggestions: [EnergySuggestion] = []
    @Published var isRefreshing: Bool = false
    @Published var lastAnomaly: AnomalyEvent?

    private let connectionManager = HAConnectionManager.shared
    private let discoveryManager = EnergyDiscoveryManager.shared
    private let costCalculator = CostCalculator.shared
    private let suggestionEngine = SuggestionEngine.shared
    private let anomalyDetector = AnomalyDetector.shared
    private let dataReliability = DataReliabilityEngine.shared
    private let notificationScheduler = NotificationScheduler.shared

    private var cancellables = Set<AnyCancellable>()
    private var modelContext: ModelContext?

    init() {
        observeEntities()
        observeConnectionState()
    }

    func setModelContext(_ context: ModelContext) {
        self.modelContext = context
        Task { await refreshChartData() }
    }

    private func observeEntities() {
        connectionManager.entityPublisher
            .receive(on: RunLoop.main)
            .sink { [weak self] entity in
                self?.handleEntityUpdate(entity)
            }
            .store(in: &cancellables)

        discoveryManager.$solarEntities
            .combineLatest(discoveryManager.$gridEntities, discoveryManager.$batteryEntities, discoveryManager.$consumptionEntities)
            .receive(on: RunLoop.main)
            .sink { [weak self] _ in
                self?.updateCurrentValues()
            }
            .store(in: &cancellables)
    }

    private func observeConnectionState() {
        connectionManager.$connectionState
            .receive(on: RunLoop.main)
            .sink { [weak self] state in
                if state.isConnected {
                    self?.updateCurrentValues()
                }
            }
            .store(in: &cancellables)
    }

    private func handleEntityUpdate(_ entity: HAEntity) {
        guard let value = entity.numericValue else { return }

        switch entity.category {
        case .solar:
            if currentSolar > 0 && abs(value - currentSolar) / max(currentSolar, 1) > 0.2 {
                HapticManager.powerChange()
            }
            currentSolar = value
        case .grid:
            currentGrid = value
        case .battery:
            if entity.unit?.lowercased() == "%" {
                batteryPercentage = value
            } else {
                currentBattery = value
            }
        case .consumption:
            currentConsumption = value
        case .unknown:
            break
        }

        let hour = Calendar.current.component(.hour, from: Date())
        anomalyDetector.updateUsageProfile(hour: hour, consumption: currentConsumption)

        let now = Date()
        let point = EnergyDataPoint(
            timestamp: now,
            solarProduction: currentSolar,
            gridImport: max(0, currentGrid),
            gridExport: max(0, -currentGrid),
            batteryDischarge: max(0, currentBattery),
            batteryCharge: max(0, -currentBattery),
            totalConsumption: currentConsumption,
            costPerKWh: costCalculator.currentRate()
        )
        dataReliability.cacheSample(point)
        persistEnergyRecord(entity: entity, value: value)

        Task { await checkAnomaly() }
    }

    private func updateCurrentValues() {
        let solarSum = discoveryManager.solarEntities.compactMap { $0.numericValue }.reduce(0, +)
        let gridSum = discoveryManager.gridEntities.compactMap { $0.numericValue }.reduce(0, +)
        let batterySum = discoveryManager.batteryEntities.compactMap { $0.numericValue }.reduce(0, +)
        let consumptionSum = discoveryManager.consumptionEntities.compactMap { $0.numericValue }.reduce(0, +)

        currentSolar = solarSum
        currentGrid = gridSum
        currentBattery = batterySum
        currentConsumption = consumptionSum

        updateCostResult()
        updateSuggestions()
    }

    private func updateCostResult() {
        let today = TimeRange.today.dateInterval
        let solarKWh = currentSolar * 0.25
        let gridImportKWh = max(0, currentGrid) * 0.25
        let gridExportKWh = max(0, -currentGrid) * 0.25
        costResult = costCalculator.calculateCost(
            gridImportKWh: gridImportKWh,
            gridExportKWh: gridExportKWh,
            solarProductionKWh: solarKWh,
            at: Date()
        )
        _ = today
    }

    private func updateSuggestions() {
        let currentPrice = costCalculator.currentRate()
        let averagePrice = costCalculator.averageRate()
        suggestions = suggestionEngine.generateSuggestions(
            currentSolar: currentSolar,
            currentConsumption: currentConsumption,
            currentBattery: batteryPercentage,
            currentPrice: currentPrice,
            averagePrice: averagePrice
        )
    }

    private func checkAnomaly() async {
        let hour = Calendar.current.component(.hour, from: Date())
        if let event = anomalyDetector.check(currentConsumption: currentConsumption, hour: hour) {
            lastAnomaly = event
        }
    }

    func refresh() async {
        isRefreshing = true
        await connectionManager.connect()
        updateCurrentValues()
        await refreshChartData()
        isRefreshing = false
        HapticManager.light()
    }

    func refreshChartData() async {
        guard let context = modelContext else { return }
        let range = selectedTimeRange.dateInterval

        let descriptor = FetchDescriptor<EnergyRecord>(
            predicate: #Predicate { $0.timestamp >= range.start && $0.timestamp <= range.end },
            sortBy: [SortDescriptor(\.timestamp)]
        )

        do {
            let records = try context.fetch(descriptor)
            let grouped = Dictionary(grouping: records, by: { record in
                Calendar.current.startOfDay(for: record.timestamp)
            })

            var points: [EnergyDataPoint] = []
            for (day, dayRecords) in grouped {
                let solar = dayRecords.filter { $0.category == "solar" }.reduce(0.0) { $0 + $1.value }
                let grid = dayRecords.filter { $0.category == "grid" }.reduce(0.0) { $0 + $1.value }
                let battery = dayRecords.filter { $0.category == "battery" }.reduce(0.0) { $0 + $1.value }
                let consumption = dayRecords.filter { $0.category == "consumption" }.reduce(0.0) { $0 + $1.value }

                points.append(EnergyDataPoint(
                    timestamp: day,
                    solarProduction: solar,
                    gridImport: max(0, grid),
                    gridExport: max(0, -grid),
                    batteryDischarge: max(0, battery),
                    batteryCharge: max(0, -battery),
                    totalConsumption: consumption,
                    costPerKWh: costCalculator.currentRate()
                ))
            }
            chartData = points.sorted { $0.timestamp < $1.timestamp }
        } catch {
            chartData = []
        }
    }

    func setTimeRange(_ range: TimeRange) {
        selectedTimeRange = range
        Task { await refreshChartData() }
    }

    private func persistEnergyRecord(entity: HAEntity, value: Double) {
        guard let context = modelContext else { return }
        let now = Date()
        let lastMinute = now.addingTimeInterval(-60)
        let descriptor = FetchDescriptor<EnergyRecord>(
            predicate: #Predicate { $0.entityId == entity.entityId && $0.timestamp >= lastMinute },
            sortBy: [SortDescriptor(\.timestamp)]
        )
        if let existing = try? context.fetch(descriptor), !existing.isEmpty {
            return
        }

        let record = EnergyRecord(
            entityId: entity.entityId,
            value: value,
            unit: entity.unit ?? "kW",
            category: entity.category.rawValue,
            timestamp: now
        )
        context.insert(record)
        try? context.save()
    }

    func dismissSuggestion(_ suggestion: EnergySuggestion) {
        suggestionEngine.dismiss(suggestion)
        suggestions.removeAll { $0.id == suggestion.id }
    }

    func setReminderForSuggestion(_ suggestion: EnergySuggestion, at date: Date) {
        Task {
            await notificationScheduler.scheduleSuggestionReminder(suggestion, at: date)
        }
    }

    var formattedSolar: String {
        String(format: "%.2f kW", currentSolar)
    }

    var formattedGrid: String {
        String(format: "%.2f kW", currentGrid)
    }

    var formattedConsumption: String {
        String(format: "%.2f kW", currentConsumption)
    }

    var formattedBattery: String {
        String(format: "%.0f%%", batteryPercentage)
    }

    var formattedSavings: String {
        costResult?.formattedSavings ?? "$0.00"
    }

    var formattedCO2: String {
        costResult?.formattedCO2 ?? "0 kg"
    }
}
