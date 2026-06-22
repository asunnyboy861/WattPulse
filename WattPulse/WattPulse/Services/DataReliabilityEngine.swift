import Foundation
import Combine
import SwiftUI

@MainActor
final class DataReliabilityEngine: ObservableObject {
    static let shared = DataReliabilityEngine()

    @Published private(set) var isOffline: Bool = false
    @Published private(set) var lastCacheUpdate: Date?
    @Published private(set) var cacheAge: TimeInterval = 0

    private var cache: [Date: EnergyDataPoint] = [:]
    private let maxCacheAge: TimeInterval = 86400
    private var cacheAgeTimer: Timer?

    private init() {
        startCacheAgeTimer()
    }

    private func startCacheAgeTimer() {
        cacheAgeTimer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] _ in
            Task { @MainActor in
                self?.updateCacheAge()
            }
        }
    }

    func cacheSample(_ point: EnergyDataPoint) {
        cache[point.timestamp] = point
        cleanupOldCache()
        lastCacheUpdate = .now
        cacheAge = 0
        isOffline = false
    }

    func markOffline() {
        isOffline = true
    }

    func markOnline() {
        isOffline = false
    }

    func getCachedPoints(in range: DateInterval) -> [EnergyDataPoint] {
        cache.values
            .filter { range.contains($0.timestamp) }
            .sorted { $0.timestamp < $1.timestamp }
    }

    func getLatestCachedPoint() -> EnergyDataPoint? {
        cache.values.max(by: { $0.timestamp < $1.timestamp })
    }

    func interpolateGaps(in points: [EnergyDataPoint], range: DateInterval) -> [EnergyDataPoint] {
        guard !points.isEmpty else { return [] }
        var result = points
        let stride = TimeInterval(AppConfig.sampleIntervalMinutes * 60)

        var current = range.start
        while current < range.end {
            if !result.contains(where: { $0.timestamp.timeIntervalSince(current) < stride / 2 }) {
                if let before = result.last(where: { $0.timestamp < current }),
                   let after = result.first(where: { $0.timestamp > current }) {
                    let ratio = current.timeIntervalSince(before.timestamp) / after.timestamp.timeIntervalSince(before.timestamp)
                    let interpolated = EnergyDataPoint(
                        timestamp: current,
                        solarProduction: before.solarProduction + (after.solarProduction - before.solarProduction) * ratio,
                        gridImport: before.gridImport + (after.gridImport - before.gridImport) * ratio,
                        gridExport: before.gridExport + (after.gridExport - before.gridExport) * ratio,
                        batteryDischarge: before.batteryDischarge + (after.batteryDischarge - before.batteryDischarge) * ratio,
                        batteryCharge: before.batteryCharge + (after.batteryCharge - before.batteryCharge) * ratio,
                        totalConsumption: before.totalConsumption + (after.totalConsumption - before.totalConsumption) * ratio,
                        costPerKWh: before.costPerKWh
                    )
                    result.append(interpolated)
                }
            }
            current = current.addingTimeInterval(stride)
        }
        return result.sorted { $0.timestamp < $1.timestamp }
    }

    private func cleanupOldCache() {
        let cutoff = Date().addingTimeInterval(-maxCacheAge)
        cache = cache.filter { $0.key > cutoff }
    }

    func updateCacheAge() {
        if let last = lastCacheUpdate {
            cacheAge = Date().timeIntervalSince(last)
        }
    }

    var cacheAgeText: String {
        if cacheAge < 60 { return "Just now" }
        if cacheAge < 3600 { return "\(Int(cacheAge / 60)) min ago" }
        return "\(Int(cacheAge / 3600)) hr ago"
    }
}
