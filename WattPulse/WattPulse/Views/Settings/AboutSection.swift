import SwiftUI

struct AboutSection: View {
    @ObservedObject var viewModel: SettingsViewModel
    @State private var showingContactSupport: Bool = false

    var body: some View {
        Section {
            NavigationLink {
                ContactSupportView()
            } label: {
                Label("Contact Support", systemImage: "envelope.fill")
            }

            Link(destination: URL(string: AppConfig.supportPageURL)!) {
                Label("Support Page", systemImage: "questionmark.circle")
            }

            Link(destination: URL(string: AppConfig.privacyPageURL)!) {
                Label("Privacy Policy", systemImage: "lock.shield")
            }

            HStack {
                Image(systemName: "info.circle")
                Text("Version")
                Spacer()
                Text(viewModel.appVersion)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        } header: {
            Text("About")
        }
    }
}
