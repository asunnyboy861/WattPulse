import SwiftUI

struct TimeRangePicker: View {
    @Binding var selectedRange: TimeRange

    var body: some View {
        HStack(spacing: 8) {
            ForEach(TimeRange.allCases) { range in
                Button {
                    withAnimation(.spring(response: 0.3)) {
                        selectedRange = range
                    }
                    HapticManager.light()
                } label: {
                    Text(range.displayName)
                        .font(.caption.bold())
                        .padding(.horizontal, 12)
                        .padding(.vertical, 6)
                        .background(selectedRange == range ? Color.accentColor : Color(.secondarySystemBackground))
                        .foregroundStyle(selectedRange == range ? .white : .primary)
                        .clipShape(Capsule())
                }
                .buttonStyle(.plain)
                .accessibilityLabel("Time range: \(range.displayName)")
            }
        }
    }
}
