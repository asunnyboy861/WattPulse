import SwiftUI

struct WeeklySummaryCard: View {
    let summary: WeeklySummary?

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Weekly Summary")
                .font(.headline)

            if let summary = summary {
                HStack(spacing: 16) {
                    metricItem(label: "Solar", value: summary.formattedSolar, color: .green)
                    metricItem(label: "Used", value: summary.formattedConsumption, color: .orange)
                    metricItem(label: "Saved", value: summary.formattedSavings, color: .blue)
                    metricItem(label: "CO₂", value: summary.formattedCO2, color: .green)
                }
            } else {
                Text("No data for this week yet.")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        }
        .padding()
        .background(Color(.secondarySystemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }

    private func metricItem(label: String, value: String, color: Color) -> some View {
        VStack(spacing: 4) {
            Text(value)
                .font(.subheadline.bold())
                .foregroundStyle(color)
            Text(label)
                .font(.caption2)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity)
    }
}
