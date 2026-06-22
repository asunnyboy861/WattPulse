import SwiftUI

struct WelcomeView: View {
    @Binding var hasStartedOnboarding: Bool

    var body: some View {
        VStack(spacing: 0) {
            Spacer()

            VStack(spacing: 24) {
                ZStack {
                    Circle()
                        .fill(LinearGradient(colors: [.green, .blue], startPoint: .topLeading, endPoint: .bottomTrailing))
                        .frame(width: 120, height: 120)
                        .shadow(color: .green.opacity(0.3), radius: 20, y: 10)
                    Image(systemName: "bolt.heart.fill")
                        .font(.system(size: 56))
                        .foregroundStyle(.white)
                }

                VStack(spacing: 8) {
                    Text("WattPulse")
                        .font(.largeTitle.bold())
                    Text("See your home's energy heartbeat")
                        .font(.body)
                        .foregroundStyle(.secondary)
                        .multilineTextAlignment(.center)
                }
            }

            Spacer()

            VStack(spacing: 12) {
                featureRow(icon: "chart.xyaxis.line", title: "Multi-Source Overlay", subtitle: "Solar, grid, battery, and cost on one chart", color: .green)
                featureRow(icon: "brain.head.profile", title: "AI Smart Suggestions", subtitle: "On-device Core ML recommendations", color: .blue)
                featureRow(icon: "leaf.fill", title: "CO₂ Tracking", subtitle: "See your carbon offset in real time", color: .teal)
            }
            .padding()
            .background(Color(.secondarySystemBackground))
            .clipShape(RoundedRectangle(cornerRadius: 16))

            Spacer()
            Spacer()

            Button {
                HapticManager.medium()
                hasStartedOnboarding = true
            } label: {
                Text("Get Started")
                    .font(.headline)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.accentColor)
                    .foregroundStyle(.white)
                    .clipShape(RoundedRectangle(cornerRadius: 12))
            }
            .padding(.horizontal)
        }
        .padding()
    }

    private func featureRow(icon: String, title: String, subtitle: String, color: Color) -> some View {
        HStack(spacing: 12) {
            ZStack {
                Circle()
                    .fill(color.opacity(0.15))
                    .frame(width: 36, height: 36)
                Image(systemName: icon)
                    .font(.callout)
                    .foregroundStyle(color)
            }
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.subheadline.bold())
                Text(subtitle)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            Spacer()
        }
    }
}
