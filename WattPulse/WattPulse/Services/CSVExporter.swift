import Foundation
import UIKit

@MainActor
final class CSVExporter {
    static let shared = CSVExporter()

    private init() {}

    func export(summaries: [DailySummary]) -> URL? {
        var csv = "Date,Solar Production (kWh),Grid Import (kWh),Grid Export (kWh),Battery Discharge (kWh),Battery Charge (kWh),Total Consumption (kWh),Total Cost ($),Solar Revenue ($),CO2 Offset (kg)\n"

        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        formatter.timeZone = .current

        for summary in summaries.sorted(by: { $0.date < $1.date }) {
            let row = [
                formatter.string(from: summary.date),
                String(format: "%.3f", summary.solarProductionKWh),
                String(format: "%.3f", summary.gridImportKWh),
                String(format: "%.3f", summary.gridExportKWh),
                String(format: "%.3f", summary.batteryDischargeKWh),
                String(format: "%.3f", summary.batteryChargeKWh),
                String(format: "%.3f", summary.totalConsumptionKWh),
                String(format: "%.2f", summary.totalCost),
                String(format: "%.2f", summary.solarRevenue),
                String(format: "%.2f", summary.co2OffsetKg)
            ].joined(separator: ",")
            csv += row + "\n"
        }

        guard let documentsURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first else { return nil }
        let fileURL = documentsURL.appendingPathComponent("WattPulse_Export_\(formatter.string(from: Date())).csv")

        do {
            try csv.write(to: fileURL, atomically: true, encoding: .utf8)
            return fileURL
        } catch {
            return nil
        }
    }

    func shareCSV(at url: URL) {
        let activityVC = UIActivityViewController(activityItems: [url], applicationActivities: nil)
        guard let scene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
              let rootVC = scene.windows.first?.rootViewController else { return }
        rootVC.present(activityVC, animated: true)
    }
}
