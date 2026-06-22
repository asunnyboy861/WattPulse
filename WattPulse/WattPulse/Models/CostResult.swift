import Foundation

struct CostResult: Codable {
    let importCost: Double
    let exportCredit: Double
    let netCost: Double
    let co2OffsetKg: Double
    let solarRevenue: Double

    var formattedNetCost: String {
        String(format: "$%.2f", netCost)
    }

    var formattedImportCost: String {
        String(format: "$%.2f", importCost)
    }

    var formattedExportCredit: String {
        String(format: "$%.2f", exportCredit)
    }

    var formattedCO2: String {
        if co2OffsetKg >= 1000 {
            return String(format: "%.1f t", co2OffsetKg / 1000)
        }
        return String(format: "%.1f kg", co2OffsetKg)
    }

    var formattedSolarRevenue: String {
        String(format: "$%.2f", solarRevenue)
    }

    var savings: Double {
        max(0, solarRevenue + exportCredit - importCost)
    }

    var formattedSavings: String {
        String(format: "$%.2f", savings)
    }
}
