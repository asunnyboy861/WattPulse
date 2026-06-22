import SwiftUI
import Charts

struct HourlyCurveChart: View {
    let data: [EnergyDataPoint]

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("24-Hour Curve")
                .font(.headline)

            if data.isEmpty {
                Text("No data available for today.")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .frame(maxWidth: .infinity, alignment: .center)
                    .padding(.vertical, 40)
            } else {
                Chart {
                    ForEach(data) { point in
                        LineMark(
                            x: .value("Hour", point.timestamp),
                            y: .value("Solar", point.solarProduction)
                        )
                        .foregroundStyle(.green)
                        .interpolationMethod(.catmullRom)

                        LineMark(
                            x: .value("Hour", point.timestamp),
                            y: .value("Consumption", point.totalConsumption)
                        )
                        .foregroundStyle(.orange)
                        .interpolationMethod(.catmullRom)

                        LineMark(
                            x: .value("Hour", point.timestamp),
                            y: .value("Grid", point.gridImport)
                        )
                        .foregroundStyle(.red)
                        .interpolationMethod(.catmullRom)
                    }
                }
                .chartXAxis {
                    AxisMarks(values: .stride(by: .hour, count: 4)) { _ in
                        AxisGridLine()
                        AxisValueLabel(format: .dateTime.hour())
                    }
                }
                .chartYAxis {
                    AxisMarks(position: .leading)
                }
                .frame(height: 200)
            }
        }
        .padding()
        .background(Color(.secondarySystemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }
}
