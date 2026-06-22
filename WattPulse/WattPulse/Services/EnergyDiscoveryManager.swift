import Foundation
import Combine

@MainActor
final class EnergyDiscoveryManager: ObservableObject {
    static let shared = EnergyDiscoveryManager()

    @Published private(set) var solarEntities: [HAEntity] = []
    @Published private(set) var gridEntities: [HAEntity] = []
    @Published private(set) var batteryEntities: [HAEntity] = []
    @Published private(set) var consumptionEntities: [HAEntity] = []
    @Published private(set) var isDiscovering: Bool = false

    private var cancellables = Set<AnyCancellable>()
    private let connectionManager = HAConnectionManager.shared

    private init() {
        observeEntities()
    }

    private func observeEntities() {
        connectionManager.$entities
            .sink { [weak self] entities in
                self?.categorize(entities)
            }
            .store(in: &cancellables)
    }

    func discover(from connectionManager: HAConnectionManager) {
        isDiscovering = true
        categorize(connectionManager.entities)
        isDiscovering = false
    }

    private func categorize(_ entities: [HAEntity]) {
        solarEntities = entities.filter { $0.category == .solar }
        gridEntities = entities.filter { $0.category == .grid }
        batteryEntities = entities.filter { $0.category == .battery }
        consumptionEntities = entities.filter { $0.category == .consumption }
        saveCategoryMapping(entities)
    }

    private func saveCategoryMapping(_ entities: [HAEntity]) {
        let mapping = entities.reduce(into: [String: String]()) { dict, entity in
            dict[entity.entityId] = entity.category.rawValue
        }
        if let data = try? JSONSerialization.data(withJSONObject: mapping) {
            UserDefaults.standard.set(data, forKey: "HA_CATEGORY_MAPPING")
        }
    }

    var totalEntityCount: Int {
        solarEntities.count + gridEntities.count + batteryEntities.count + consumptionEntities.count
    }

    var hasDiscoveredEntities: Bool {
        totalEntityCount > 0
    }
}
