import Foundation
import SwiftUI
import SwiftData
import Combine

@MainActor
final class AppEnvironment: ObservableObject {
    static let shared = AppEnvironment()

    let connectionManager = HAConnectionManager.shared
    let discoveryManager = EnergyDiscoveryManager.shared
    let costCalculator = CostCalculator.shared
    let suggestionEngine = SuggestionEngine.shared
    let anomalyDetector = AnomalyDetector.shared
    let dataReliability = DataReliabilityEngine.shared
    let notificationScheduler = NotificationScheduler.shared
    let csvExporter = CSVExporter.shared

    @Published var hasCompletedOnboarding: Bool {
        didSet {
            UserDefaults.standard.set(hasCompletedOnboarding, forKey: "HAS_COMPLETED_ONBOARDING")
        }
    }

    @Published var selectedTab: Int = 0

    let modelContainer: ModelContainer

    private var cancellables = Set<AnyCancellable>()

    private init() {
        self.hasCompletedOnboarding = UserDefaults.standard.bool(forKey: "HAS_COMPLETED_ONBOARDING")

        do {
            let schema = Schema([EnergyRecord.self, DailySummary.self])
            let config = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)
            self.modelContainer = try ModelContainer(for: schema, configurations: [config])
        } catch {
            let schema = Schema([EnergyRecord.self, DailySummary.self])
            let config = ModelConfiguration(schema: schema, isStoredInMemoryOnly: true)
            self.modelContainer = try! ModelContainer(for: schema, configurations: [config])
        }

        observeConnectionState()
    }

    private func observeConnectionState() {
        connectionManager.$connectionState
            .sink { [weak self] state in
                if state.isConnected {
                    self?.dataReliability.markOnline()
                } else if case .error = state {
                    self?.dataReliability.markOffline()
                }
            }
            .store(in: &cancellables)
    }

    func completeOnboarding() {
        hasCompletedOnboarding = true
        selectedTab = 0
    }

    func resetOnboarding() {
        hasCompletedOnboarding = false
        connectionManager.disconnect()
    }
}
