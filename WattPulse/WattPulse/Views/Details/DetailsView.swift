import SwiftUI
import SwiftData

struct DetailsView: View {
    @EnvironmentObject private var env: AppEnvironment
    @Environment(\.modelContext) private var modelContext
    @StateObject private var viewModel = DetailsViewModel()

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 16) {
                    summaryGrid

                    HourlyCurveChart(data: viewModel.hourlyData)

                    MonthlyBarChart(data: viewModel.monthlyData)

                    entityListSection(title: "Solar Entities", entities: viewModel.solarEntities, color: .green)
                    entityListSection(title: "Grid Entities", entities: viewModel.gridEntities, color: .red)
                    entityListSection(title: "Battery Entities", entities: viewModel.batteryEntities, color: .blue)
                    entityListSection(title: "Consumption Entities", entities: viewModel.consumptionEntities, color: .orange)
                }
                .padding()
                .frame(maxWidth: 720)
                .frame(maxWidth: .infinity)
            }
            .background(Color(.systemBackground))
            .navigationTitle("Details")
            .onAppear {
                viewModel.setModelContext(modelContext)
            }
        }
    }

    private var summaryGrid: some View {
        LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 12) {
            summaryCard(title: "Total Solar", value: viewModel.formattedTotalSolar, color: .green, icon: "sun.max.fill")
            summaryCard(title: "Total Consumption", value: viewModel.formattedTotalConsumption, color: .orange, icon: "house.fill")
            summaryCard(title: "Grid Import", value: viewModel.formattedTotalGridImport, color: .red, icon: "bolt.fill")
            summaryCard(title: "Grid Export", value: viewModel.formattedTotalGridExport, color: .purple, icon: "arrow.up.right")
            summaryCard(title: "Total Cost", value: viewModel.formattedTotalCost, color: .red, icon: "dollarsign.circle.fill")
            summaryCard(title: "CO₂ Offset", value: viewModel.formattedTotalCO2, color: .green, icon: "leaf.fill")
        }
    }

    private func summaryCard(title: String, value: String, color: Color, icon: String) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack {
                Image(systemName: icon)
                    .foregroundStyle(color)
                Spacer()
            }
            Text(value)
                .font(.headline)
            Text(title)
                .font(.caption)
                .foregroundStyle(.secondary)
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color(.secondarySystemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }

    private func entityListSection(title: String, entities: [HAEntity], color: Color) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.headline)
            if entities.isEmpty {
                Text("No entities discovered.")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            } else {
                ForEach(entities) { entity in
                    EntityDetailView(entity: entity)
                }
            }
        }
    }
}
