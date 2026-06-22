import SwiftUI

struct EntityDiscoveryView: View {
    @EnvironmentObject private var env: AppEnvironment
    let onComplete: () -> Void
    @State private var hasStarted: Bool = false

    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                VStack(spacing: 12) {
                    Image(systemName: "magnifyingglass.circle.fill")
                        .font(.system(size: 48))
                        .foregroundStyle(.green)
                    Text("Discovering Entities")
                        .font(.title2.bold())
                    Text("We found \(env.discoveryManager.totalEntityCount) energy entities in your Home Assistant.")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                        .multilineTextAlignment(.center)
                }

                entitySection(title: "Solar", entities: env.discoveryManager.solarEntities, color: .green, icon: "sun.max.fill")
                entitySection(title: "Grid", entities: env.discoveryManager.gridEntities, color: .red, icon: "bolt.fill")
                entitySection(title: "Battery", entities: env.discoveryManager.batteryEntities, color: .blue, icon: "battery.100.bolt")
                entitySection(title: "Consumption", entities: env.discoveryManager.consumptionEntities, color: .orange, icon: "house.fill")

                Button {
                    HapticManager.success()
                    onComplete()
                } label: {
                    Text("Start Monitoring")
                        .font(.headline)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.accentColor)
                        .foregroundStyle(.white)
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                }
                .disabled(env.discoveryManager.totalEntityCount == 0)
            }
            .padding()
            .frame(maxWidth: 600)
            .frame(maxWidth: .infinity)
        }
        .background(Color(.systemBackground))
        .navigationTitle("Discovery")
        .onAppear {
            env.discoveryManager.discover(from: env.connectionManager)
        }
    }

    private func entitySection(title: String, entities: [HAEntity], color: Color, icon: String) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Image(systemName: icon)
                    .foregroundStyle(color)
                Text("\(title) (\(entities.count))")
                    .font(.headline)
            }
            if entities.isEmpty {
                Text("No \(title.lowercased()) entities found.")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            } else {
                ForEach(entities.prefix(5)) { entity in
                    HStack {
                        Text(entity.name)
                            .font(.subheadline)
                        Spacer()
                        Text(entity.displayValue)
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                    .padding(.vertical, 4)
                    .padding(.horizontal, 8)
                    .background(Color(.secondarySystemBackground))
                    .clipShape(RoundedRectangle(cornerRadius: 8))
                }
                if entities.count > 5 {
                    Text("…and \(entities.count - 5) more")
                        .font(.caption2)
                        .foregroundStyle(.secondary)
                }
            }
        }
        .padding()
        .background(Color(.secondarySystemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }
}
