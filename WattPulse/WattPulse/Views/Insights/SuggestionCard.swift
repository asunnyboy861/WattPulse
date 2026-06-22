import SwiftUI

struct SuggestionCard: View {
    let suggestion: EnergySuggestion
    let onDismiss: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack(alignment: .top, spacing: 12) {
                Image(systemName: suggestion.type.iconName)
                    .font(.title3)
                    .foregroundStyle(colorForType(suggestion.type))
                    .frame(width: 32)

                VStack(alignment: .leading, spacing: 4) {
                    Text(suggestion.title)
                        .font(.subheadline.bold())
                    Text(suggestion.description)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                        .fixedSize(horizontal: false, vertical: true)

                    if suggestion.potentialSaving > 0 {
                        Text(suggestion.formattedSaving)
                            .font(.caption.bold())
                            .foregroundStyle(.green)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 2)
                            .background(Color.green.opacity(0.1))
                            .clipShape(Capsule())
                    }
                }

                Spacer()

                Button {
                    HapticManager.light()
                    onDismiss()
                } label: {
                    Image(systemName: "xmark")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                .buttonStyle(.plain)
            }
        }
        .padding()
        .background(Color(.secondarySystemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .accessibilityElement(children: .combine)
        .accessibilityLabel("\(suggestion.title). \(suggestion.description)")
    }

    private func colorForType(_ type: SuggestionType) -> Color {
        switch type {
        case .solarExcess: return .green
        case .lowPrice: return .blue
        case .anomaly: return .red
        case .batteryOptimize: return .purple
        }
    }
}
