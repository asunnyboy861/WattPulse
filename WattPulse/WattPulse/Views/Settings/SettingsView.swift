import SwiftUI
import SwiftData

struct SettingsView: View {
    @EnvironmentObject private var env: AppEnvironment
    @Environment(\.modelContext) private var modelContext
    @StateObject private var viewModel = SettingsViewModel()

    var body: some View {
        NavigationStack {
            Form {
                HAConnectionSection()

                RatePlanSection(viewModel: viewModel)

                NotificationsSection(viewModel: viewModel)

                AppearanceSection()

                Section {
                    Picker("Export Range", selection: $viewModel.csvExportRange) {
                        ForEach(TimeRange.allCases) { range in
                            Text(range.displayName).tag(range)
                        }
                    }
                    Button {
                        viewModel.exportCSV()
                    } label: {
                        Label("Export CSV", systemImage: "square.and.arrow.up")
                    }
                    if let error = viewModel.exportError {
                        Text(error)
                            .font(.caption)
                            .foregroundStyle(.red)
                    }
                } header: {
                    Text("Data Export")
                }

                AboutSection(viewModel: viewModel)
            }
            .navigationTitle("Settings")
            .onAppear {
                viewModel.setModelContext(modelContext)
            }
        }
    }
}
