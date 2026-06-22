import SwiftUI

struct MetricCard: View {
    let title: String
    let value: String
    let iconName: String
    let color: Color
    let subtitle: String?

    init(title: String, value: String, iconName: String, color: Color, subtitle: String? = nil) {
        self.title = title
        self.value = value
        self.iconName = iconName
        self.color = color
        self.subtitle = subtitle
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Image(systemName: iconName)
                    .font(.title3)
                    .foregroundStyle(color)
                Spacer()
            }
            Text(value)
                .font(.system(.title2, design: .rounded).bold())
                .foregroundStyle(.primary)
                .accessibilityLabel("\(title): \(value)")
            Text(title)
                .font(.caption)
                .foregroundStyle(.secondary)
            if let subtitle = subtitle {
                Text(subtitle)
                    .font(.caption2)
                    .foregroundStyle(.secondary)
            }
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color(.secondarySystemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }
}
