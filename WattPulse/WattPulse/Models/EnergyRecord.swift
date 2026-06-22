import Foundation
import SwiftData

@Model
final class EnergyRecord {
    @Attribute(.unique) var id: UUID
    var entityId: String
    var value: Double
    var unit: String
    var category: String
    var timestamp: Date

    init(entityId: String, value: Double, unit: String, category: String, timestamp: Date = .now) {
        self.id = UUID()
        self.entityId = entityId
        self.value = value
        self.unit = unit
        self.category = category
        self.timestamp = timestamp
    }

    var energyCategory: EnergyCategory {
        EnergyCategory(rawValue: category) ?? .unknown
    }
}
