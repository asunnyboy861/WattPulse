import SwiftUI

struct EnergyFlowDiagram: View {
    let solarPower: Double
    let gridPower: Double
    let batteryPower: Double
    let consumption: Double

    @State private var animationProgress: Double = 0

    private var solarToHome: Double { min(solarPower, consumption) }
    private var solarToBattery: Double { max(0, min(solarPower - consumption, batteryPower > 0 ? 0 : 5)) }
    private var solarToGrid: Double { max(0, solarPower - consumption - solarToBattery) }
    private var gridToHome: Double { max(0, consumption - solarPower) }
    private var batteryToHome: Double { max(0, batteryPower) }

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Energy Flow")
                .font(.headline)

            ZStack {
                RoundedRectangle(cornerRadius: 16)
                    .fill(Color(.secondarySystemBackground))

                VStack(spacing: 20) {
                    HStack {
                        nodeView(icon: "sun.max.fill", label: "Solar", value: solarPower, color: .green)
                        Spacer()
                        nodeView(icon: "house.fill", label: "Home", value: consumption, color: .orange)
                        Spacer()
                        nodeView(icon: "bolt.fill", label: "Grid", value: gridPower, color: .red)
                    }

                    HStack {
                        Spacer()
                        nodeView(icon: "battery.100.bolt", label: "Battery", value: batteryPower, color: .blue)
                        Spacer()
                    }
                }
                .padding()
            }
            .frame(height: 200)
        }
        .padding()
        .background(Color(.secondarySystemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .onAppear {
            withAnimation(.easeInOut(duration: 1.5).repeatForever(autoreverses: true)) {
                animationProgress = 1.0
            }
        }
    }

    private func nodeView(icon: String, label: String, value: Double, color: Color) -> some View {
        VStack(spacing: 6) {
            ZStack {
                Circle()
                    .fill(color.opacity(0.2))
                    .frame(width: 56, height: 56)
                Image(systemName: icon)
                    .font(.title2)
                    .foregroundStyle(color)
            }
            Text(label)
                .font(.caption.bold())
            Text(String(format: "%.1f kW", value))
                .font(.caption2)
                .foregroundStyle(.secondary)
        }
        .accessibilityElement(children: .combine)
        .accessibilityLabel("\(label): \(String(format: "%.1f", value)) kW")
    }
}
