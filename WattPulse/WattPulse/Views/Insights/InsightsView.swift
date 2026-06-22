import SwiftUI

struct InsightsView: View {
    @EnvironmentObject private var env: AppEnvironment
    @StateObject private var viewModel = InsightsViewModel()

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 16) {
                    WeeklySummaryCard(summary: viewModel.weeklySummary)

                    if !viewModel.suggestions.isEmpty {
                        VStack(alignment: .leading, spacing: 8) {
                            Text("AI Suggestions")
                                .font(.headline)

                            ForEach(viewModel.suggestions) { suggestion in
                                SuggestionCard(suggestion: suggestion) {
                                    viewModel.dismissSuggestion(suggestion)
                                }
                            }
                        }
                    }

                    AnomalyHistoryCard(anomalies: viewModel.anomalies) { event in
                        viewModel.markAnomalyAsNormal(event)
                    }
                }
                .padding()
                .frame(maxWidth: 720)
                .frame(maxWidth: .infinity)
            }
            .background(Color(.systemBackground))
            .navigationTitle("Insights")
            .refreshable {
                await viewModel.refresh()
            }
            .onAppear {
                Task { await viewModel.refresh() }
            }
        }
    }
}
