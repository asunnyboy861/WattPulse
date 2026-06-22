import SwiftUI

struct EnergyFlowDiagram: View {
    let solarPower: Double
    let gridPower: Double
    let batteryPower: Double
    let consumption: Double

    @State private var dashOffset: CGFloat = 0

    private var solarToHome: Double { min(solarPower, consumption) }
    private var solarToBattery: Double { max(0, min(solarPower - consumption, 5)) }
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

                VStack(spacing: 16) {
                    HStack(spacing: 0) {
                        nodeView(icon: "sun.max.fill", label: "Solar", value: solarPower, color: .green)

                        flowArrow(value: solarToHome, color: .green, direction: .right)

                        nodeView(icon: "house.fill", label: "Home", value: consumption, color: .orange)

                        flowArrow(value: gridToHome, color: .red, direction: .left)

                        nodeView(icon: "bolt.fill", label: "Grid", value: gridPower, color: .red)
                    }

                    HStack(spacing: 40) {
                        flowArrow(value: solarToBattery, color: .green, direction: .down)

                        flowArrow(value: batteryToHome, color: .blue, direction: .up)

                        nodeView(icon: "battery.100.bolt", label: "Battery", value: batteryPower, color: .blue)
                    }
                }
                .padding()
            }
            .frame(height: 220)
        }
        .padding()
        .background(Color(.secondarySystemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .onAppear {
            withAnimation(.linear(duration: 1.0).repeatForever(autoreverses: false)) {
                dashOffset = 8
            }
        }
    }

    private func nodeView(icon: String, label: String, value: Double, color: Color) -> some View {
        VStack(spacing: 6) {
            ZStack {
                Circle()
                    .fill(color.opacity(0.2))
                    .frame(width: 52, height: 52)
                Image(systemName: icon)
                    .font(.title3)
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

    private func flowArrow(value: Double, color: Color, direction: FlowDirection) -> some View {
        Group {
            if value > 0.1 {
                VStack(spacing: 2) {
                    if direction == .right || direction == .left {
                        HStack(spacing: 2) {
                            if direction == .left {
                                Image(systemName: "chevron.left")
                                    .font(.system(size: 8, weight: .bold))
                            }
                            DashedFlowLine(color: color, dashOffset: dashOffset)
                                .frame(width: 40, height: 2)
                            if direction == .right {
                                Image(systemName: "chevron.right")
                                    .font(.system(size: 8, weight: .bold))
                            }
                        }
                        .foregroundStyle(color)
                        Text(String(format: "%.1f", value))
                            .font(.system(size: 8))
                            .foregroundStyle(color)
                    } else {
                        if direction == .down {
                            Image(systemName: "chevron.down")
                                .font(.system(size: 8, weight: .bold))
                                .foregroundStyle(color)
                        }
                        DashedFlowLine(color: color, dashOffset: dashOffset)
                            .frame(width: 2, height: 20)
                        if direction == .up {
                            Image(systemName: "chevron.up")
                                .font(.system(size: 8, weight: .bold))
                                .foregroundStyle(color)
                        }
                    }
                }
            } else {
                Spacer().frame(width: 40, height: 20)
            }
        }
    }

    private enum FlowDirection {
        case right, left, up, down
    }
}

private struct DashedFlowLine: View {
    let color: Color
    let dashOffset: CGFloat

    var body: some View {
        GeometryReader { geo in
            Path { path in
                path.move(to: CGPoint(x: 0, y: geo.size.height / 2))
                path.addLine(to: CGPoint(x: geo.size.width, y: geo.size.height / 2))
            }
            .stroke(color, style: StrokeStyle(lineWidth: 2, dash: [4, 4], dashPhase: dashOffset))
        }
    }
}
