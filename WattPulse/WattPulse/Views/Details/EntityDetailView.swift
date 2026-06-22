import SwiftUI

struct EntityDetailView: View {
    let entity: HAEntity

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: entity.category.iconName)
                    .font(.title2)
                    .foregroundStyle(colorForCategory(entity.category))
                VStack(alignment: .leading) {
                    Text(entity.name)
                        .font(.headline)
                    Text(entity.entityId)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                Spacer()
                Text(entity.displayValue)
                    .font(.title3.bold())
            }

            Divider()

            VStack(alignment: .leading, spacing: 6) {
                if let unit = entity.unit {
                    infoRow(label: "Unit", value: unit)
                }
                if let deviceClass = entity.deviceClass {
                    infoRow(label: "Device Class", value: deviceClass)
                }
                infoRow(label: "Category", value: entity.category.displayName)
                infoRow(label: "Current State", value: entity.state)
            }
        }
        .padding()
        .background(Color(.secondarySystemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }

    private func infoRow(label: String, value: String) -> some View {
        HStack {
            Text(label)
                .font(.caption)
                .foregroundStyle(.secondary)
            Spacer()
            Text(value)
                .font(.caption.bold())
        }
    }

    private func colorForCategory(_ category: EnergyCategory) -> Color {
        switch category {
        case .solar: return .green
        case .grid: return .red
        case .battery: return .blue
        case .consumption: return .orange
        case .unknown: return .gray
        }
    }
}
