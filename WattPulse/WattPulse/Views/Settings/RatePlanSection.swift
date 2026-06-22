import SwiftUI

struct RatePlanSection: View {
    @ObservedObject var viewModel: SettingsViewModel

    var body: some View {
        Section {
            Picker("Plan Type", selection: $viewModel.ratePlan) {
                Label("Flat Rate", systemImage: "equal.square").tag(RatePlan.flat(rate: 0.15))
                Label("Time of Use", systemImage: "clock.fill").tag(RatePlan.timeOfUse(peak: 0.30, shoulder: 0.20, offPeak: 0.10, peakStartHour: 16, peakEndHour: 21))
                Label("Real-Time Pricing", systemImage: "chart.line.uptrend.xyaxis").tag(RatePlan.realTime(prices: [:]))
            }
            .pickerStyle(.menu)

            switch viewModel.ratePlan {
            case .flat:
                HStack {
                    Text("Rate ($/kWh)")
                    Spacer()
                    TextField("0.15", text: $viewModel.flatRate)
                        .keyboardType(.decimalPad)
                        .multilineTextAlignment(.trailing)
                        .frame(width: 80)
                }
            case .timeOfUse:
                rateField(label: "Peak Rate", value: $viewModel.peakRate)
                rateField(label: "Shoulder Rate", value: $viewModel.shoulderRate)
                rateField(label: "Off-Peak Rate", value: $viewModel.offPeakRate)
                HStack {
                    Text("Peak Start Hour")
                    Spacer()
                    TextField("16", text: $viewModel.peakStartHour)
                        .keyboardType(.numberPad)
                        .multilineTextAlignment(.trailing)
                        .frame(width: 60)
                }
                HStack {
                    Text("Peak End Hour")
                    Spacer()
                    TextField("21", text: $viewModel.peakEndHour)
                        .keyboardType(.numberPad)
                        .multilineTextAlignment(.trailing)
                        .frame(width: 60)
                }
            case .realTime:
                Text("Real-time pricing uses market data when available.")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            Button("Save Rate Plan") {
                viewModel.saveRatePlan()
            }
            .foregroundStyle(.blue)
        } header: {
            Text("Electricity Rate Plan")
        } footer: {
            Text("Cost calculations use this rate plan. TOU applies peak/shoulder/off-peak rates based on hour of day.")
                .font(.caption2)
        }
    }

    private func rateField(label: String, value: Binding<String>) -> some View {
        HStack {
            Text(label)
            Spacer()
            TextField("0.00", text: value)
                .keyboardType(.decimalPad)
                .multilineTextAlignment(.trailing)
                .frame(width: 80)
        }
    }
}
