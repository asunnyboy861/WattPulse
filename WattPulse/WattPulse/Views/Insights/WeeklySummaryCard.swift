import SwiftUI

struct WeeklySummaryCard: View {
    let summary: WeeklySummary?

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: "calendar.badge.clock")
                    .foregroundStyle(.blue)
                Text("Weekly Summary")
                    .font(.headline)
            }

            if let summary = summary {
                HStack(spacing: 12) {
                    metricItem(label: "Solar", value: summary.formattedSolar, color: .green, icon: "sun.max.fill")
                    metricItem(label: "Used", value: summary.formattedConsumption, color: .orange, icon: "house.fill")
                    metricItem(label: "Saved", value: summary.formattedSavings, color: .blue, icon: "dollarsign.circle.fill")
                    metricItem(label: "CO₂", value: summary.formattedCO2, color: .teal, icon: "leaf.fill")
                }
            } else {
                VStack(spacing: 8) {
                    Image(systemName: "chart.bar.doc.horizontal")
                        .font(.title2)
                        .foregroundStyle(.secondary)
                    Text("No data for this week yet.")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 16)
            }
        }
        .padding()
        .background(Color(.secondarySystemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }

    private func metricItem(label: String, value: String, color: Color, icon: String) -> some View {
        VStack(spacing: 4) {
            Image(systemName: icon)
                .font(.caption)
                .foregroundStyle(color)
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
