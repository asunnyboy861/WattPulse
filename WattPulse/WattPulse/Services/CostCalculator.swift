import Foundation

@MainActor
final class CostCalculator {
    static let shared = CostCalculator()

    private init() {}

    func loadRatePlan() -> RatePlan {
        guard let data = UserDefaults.standard.data(forKey: "RATE_PLAN"),
              let plan = try? JSONDecoder().decode(RatePlan.self, from: data) else {
            return .defaultPlan
        }
        return plan
    }

    func saveRatePlan(_ plan: RatePlan) {
        if let data = try? JSONEncoder().encode(plan) {
            UserDefaults.standard.set(data, forKey: "RATE_PLAN")
        }
    }

    func calculateCost(gridImportKWh: Double, gridExportKWh: Double, solarProductionKWh: Double, at date: Date = .now) -> CostResult {
        let plan = loadRatePlan()
        let hour = Calendar.current.component(.hour, from: date)
        let rate = plan.rateForHour(hour)

        let importCost = gridImportKWh * rate
        let exportCredit = gridExportKWh * AppConfig.defaultFeedInTariff
        let netCost = importCost - exportCredit
        let co2OffsetKg = solarProductionKWh * AppConfig.co2FactorKgPerKWh
        let solarRevenue = solarProductionKWh * AppConfig.defaultFeedInTariff

        return CostResult(
            importCost: importCost,
            exportCredit: exportCredit,
            netCost: netCost,
            co2OffsetKg: co2OffsetKg,
            solarRevenue: solarRevenue
        )
    }

    func calculateDailyCost(solarKWh: Double, gridImportKWh: Double, gridExportKWh: Double, date: Date = .now) -> CostResult {
        calculateCost(gridImportKWh: gridImportKWh, gridExportKWh: gridExportKWh, solarProductionKWh: solarKWh, at: date)
    }

    func currentRate() -> Double {
        let plan = loadRatePlan()
        let hour = Calendar.current.component(.hour, from: Date())
        return plan.rateForHour(hour)
    }

    func averageRate() -> Double {
        let plan = loadRatePlan()
        var sum: Double = 0
        for hour in 0..<24 {
            sum += plan.rateForHour(hour)
        }
        return sum / 24.0
    }
}
