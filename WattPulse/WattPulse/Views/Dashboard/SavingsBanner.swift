import SwiftUI

struct SavingsBanner: View {
    let savings: String
    let co2Offset: String
    let netCost: String

    var body: some View {
        HStack(spacing: 16) {
            VStack(alignment: .leading, spacing: 4) {
                Text("Today's Savings")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                Text(savings)
                    .font(.title.bold())
                    .foregroundStyle(.green)
            }

            Spacer()

            VStack(alignment: .center, spacing: 4) {
                Text("Net Cost")
                    .font(.caption2)
                    .foregroundStyle(.secondary)
                Text(netCost)
                    .font(.headline)
                    .foregroundStyle(.primary)
            }

            Divider()
                .frame(height: 40)

            VStack(alignment: .trailing, spacing: 4) {
                HStack(spacing: 4) {
                    Image(systemName: "leaf.fill")
                        .foregroundStyle(.green)
                    Text(co2Offset)
                        .font(.subheadline.bold())
                }
                Text("CO₂ Offset")
                    .font(.caption2)
                    .foregroundStyle(.secondary)
            }
        }
        .padding()
        .background(
            LinearGradient(colors: [.green.opacity(0.12), .blue.opacity(0.08)], startPoint: .leading, endPoint: .trailing)
        )
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .accessibilityElement(children: .combine)
        .accessibilityLabel("Today's savings: \(savings). Net cost: \(netCost). CO2 offset: \(co2Offset)")
    }
}
