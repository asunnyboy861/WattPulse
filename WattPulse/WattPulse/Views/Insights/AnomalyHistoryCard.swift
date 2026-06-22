import SwiftUI

struct AnomalyHistoryCard: View {
    let anomalies: [AnomalyEvent]
    let onMarkNormal: (AnomalyEvent) -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: "exclamationmark.triangle.fill")
                    .foregroundStyle(.orange)
                Text("Anomaly History")
                    .font(.headline)
            }

            if anomalies.isEmpty {
                Text("No anomalies detected.")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .padding(.vertical, 8)
            } else {
                ForEach(anomalies.prefix(5)) { event in
                    VStack(alignment: .leading, spacing: 4) {
                        HStack {
                            Text(event.formattedPower)
                                .font(.subheadline.bold())
                                .foregroundStyle(.red)
                            Spacer()
                            Text(event.formattedTime)
                                .font(.caption2)
                                .foregroundStyle(.secondary)
                        }
                        Text(String(format: "%.1fx normal usage", event.ratio))
                            .font(.caption)
                            .foregroundStyle(.secondary)

                        Button("It's Normal") {
                            HapticManager.light()
                            onMarkNormal(event)
                        }
                        .font(.caption)
                        .foregroundStyle(.blue)
                    }
                    .padding(.vertical, 4)
                    if event.id != anomalies.prefix(5).last?.id {
                        Divider()
                    }
                }
            }
        }
        .padding()
        .background(Color(.secondarySystemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }
}
