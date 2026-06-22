import SwiftUI
import Charts

struct MonthlyBarChart: View {
    let data: [DailySummary]

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Monthly Comparison")
                .font(.headline)

            if data.isEmpty {
                Text("No monthly data available.")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .frame(maxWidth: .infinity, alignment: .center)
                    .padding(.vertical, 40)
            } else {
                Chart {
                    ForEach(data) { summary in
                        BarMark(
                            x: .value("Month", summary.date, unit: .month),
                            y: .value("Solar", summary.solarProductionKWh)
                        )
                        .foregroundStyle(.green)

                        BarMark(
                            x: .value("Month", summary.date, unit: .month),
                            y: .value("Consumption", summary.totalConsumptionKWh)
                        )
                        .foregroundStyle(.orange)
                    }
                }
                .chartXAxis {
                    AxisMarks(values: .stride(by: .month)) { _ in
                        AxisGridLine()
                        AxisValueLabel(format: .dateTime.month(.abbreviated))
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
