import SwiftUI
import SwiftData

struct DashboardView: View {
    @EnvironmentObject private var env: AppEnvironment
    @Environment(\.modelContext) private var modelContext
    @StateObject private var viewModel = DashboardViewModel()

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 16) {
                    if env.dataReliability.isOffline {
                        offlineBanner
                    }

                    SavingsBanner(
                        savings: viewModel.formattedSavings,
                        co2Offset: viewModel.formattedCO2,
                        netCost: viewModel.costResult?.formattedNetCost ?? "$0.00"
                    )

                    HStack(spacing: 12) {
                        MetricCard(title: "Solar", value: viewModel.formattedSolar, iconName: "sun.max.fill", color: .green)
                        MetricCard(title: "Grid", value: viewModel.formattedGrid, iconName: "bolt.fill", color: .red)
                    }

                    HStack(spacing: 12) {
                        MetricCard(title: "Battery", value: viewModel.formattedBattery, iconName: "battery.100.bolt", color: .blue)
                        MetricCard(title: "Consumption", value: viewModel.formattedConsumption, iconName: "house.fill", color: .orange)
                    }

                    EnergyFlowDiagram(
                        solarPower: viewModel.currentSolar,
                        gridPower: viewModel.currentGrid,
                        batteryPower: viewModel.currentBattery,
                        consumption: viewModel.currentConsumption
                    )

                    TimeRangePicker(selectedRange: Binding(
                        get: { viewModel.selectedTimeRange },
                        set: { viewModel.setTimeRange($0) }
                    ))

                    EnergyOverlayChart(data: viewModel.chartData, timeRange: viewModel.selectedTimeRange)

                    if !viewModel.suggestions.isEmpty {
                        suggestionsSection
                    }
                }
                .padding()
                .frame(maxWidth: 720)
                .frame(maxWidth: .infinity)
            }
            .background(Color(.systemBackground))
            .navigationTitle("WattPulse")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    connectionStatusBadge
                }
            }
            .refreshable {
                await viewModel.refresh()
            }
            .onAppear {
                viewModel.setModelContext(modelContext)
            }
        }
    }

    private var offlineBanner: some View {
        HStack {
            Image(systemName: "wifi.slash")
                .foregroundStyle(.orange)
            Text("Offline — showing cached data")
                .font(.caption)
                .foregroundStyle(.secondary)
            Spacer()
            Text(env.dataReliability.cacheAgeText)
                .font(.caption2)
                .foregroundStyle(.secondary)
        }
        .padding(8)
        .background(Color.orange.opacity(0.1))
        .clipShape(RoundedRectangle(cornerRadius: 8))
    }

    private var connectionStatusBadge: some View {
        HStack(spacing: 4) {
            Circle()
                .fill(statusColor)
                .frame(width: 8, height: 8)
            Text(env.connectionManager.connectionState.displayText)
                .font(.caption2)
                .foregroundStyle(.secondary)
        }
        .accessibilityLabel("Connection status: \(env.connectionManager.connectionState.displayText)")
    }

    private var statusColor: Color {
        switch env.connectionManager.connectionState {
        case .connected: return .green
        case .connecting: return .yellow
        case .disconnected: return .gray
        case .error: return .red
        }
    }

    private var suggestionsSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Smart Suggestions")
                .font(.headline)
                .padding(.top, 8)

            ForEach(viewModel.suggestions) { suggestion in
                SuggestionCard(suggestion: suggestion) {
                    viewModel.dismissSuggestion(suggestion)
                }
            }
        }
    }
}
