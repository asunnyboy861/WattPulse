import SwiftUI
import Charts

struct EnergyOverlayChart: View {
    let data: [EnergyDataPoint]
    let timeRange: TimeRange

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            if data.isEmpty {
                emptyState
            } else {
                Chart {
                    ForEach(data) { point in
                        LineMark(
                            x: .value("Time", point.timestamp),
                            y: .value("Consumption", point.totalConsumption)
                        )
                        .foregroundStyle(Color.orange)
                        .interpolationMethod(.catmullRom)
                        .lineStyle(StrokeStyle(lineWidth: 2))

                        AreaMark(
                            x: .value("Time", point.timestamp),
                            y: .value("Solar", point.solarProduction)
                        )
                        .foregroundStyle(.linearGradient(colors: [.green.opacity(0.6), .green.opacity(0.1)], startPoint: .top, endPoint: .bottom))
                        .interpolationMethod(.catmullRom)

                        AreaMark(
                            x: .value("Time", point.timestamp),
                            y: .value("Grid Import", point.gridImport)
                        )
                        .foregroundStyle(.linearGradient(colors: [.red.opacity(0.5), .red.opacity(0.1)], startPoint: .top, endPoint: .bottom))
                        .interpolationMethod(.catmullRom)

                        AreaMark(
                            x: .value("Time", point.timestamp),
                            y: .value("Battery", point.batteryDischarge)
                        )
                        .foregroundStyle(.linearGradient(colors: [.blue.opacity(0.5), .blue.opacity(0.1)], startPoint: .top, endPoint: .bottom))
                        .interpolationMethod(.catmullRom)
                    }
                }
                .chartXAxis {
                    AxisMarks(values: .stride(by: timeRange.chartStride, count: 6)) { value in
                        AxisGridLine()
                        AxisValueLabel(format: xAxisFormat)
                    }
                }
                .chartYAxis {
                    AxisMarks(position: .leading) { value in
                        AxisGridLine()
                        AxisValueLabel("\(value.as(Double.self) ?? 0, format: .number.precision(.fractionLength(1))) kW")
                    }
                }
                .frame(height: 240)
                .accessibilityLabel("Energy chart showing solar, grid, battery, and consumption data")

                legend
            }
        }
        .padding()
        .background(Color(.secondarySystemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }

    private var xAxisFormat: Date.FormatStyle {
        switch timeRange {
        case .today: return .dateTime.hour()
        case .week: return .dateTime.weekday(.abbreviated)
        case .month: return .dateTime.day()
        case .year: return .dateTime.month(.abbreviated)
        }
    }

    private var legend: some View {
        HStack(spacing: 16) {
            LegendItem(color: .green, label: "Solar")
            LegendItem(color: .red, label: "Grid Import")
            LegendItem(color: .blue, label: "Battery")
            LegendItem(color: .orange, label: "Consumption")
        }
        .font(.caption2)
        .frame(maxWidth: .infinity)
    }

    private var emptyState: some View {
        VStack(spacing: 12) {
            Image(systemName: "chart.xyaxis.line")
                .font(.largeTitle)
                .foregroundStyle(.secondary)
            Text("No Data Yet")
                .font(.headline)
            Text("Connect to Home Assistant to see your energy data.")
                .font(.caption)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 40)
    }
}

private struct LegendItem: View {
    let color: Color
    let label: String

    var body: some View {
        HStack(spacing: 4) {
            Circle()
                .fill(color)
                .frame(width: 8, height: 8)
            Text(label)
                .foregroundStyle(.secondary)
        }
    }
}
