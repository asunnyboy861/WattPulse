import SwiftUI

struct HAConnectView: View {
    @EnvironmentObject private var env: AppEnvironment
    @State private var instanceName: String = "Home"
    @State private var haURL: String = "http://homeassistant.local:8123"
    @State private var haToken: String = ""
    @State private var isConnecting: Bool = false
    @State private var errorMessage: String?
    @State private var showDiscovery: Bool = false

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 24) {
                    VStack(spacing: 12) {
                        Image(systemName: "house.lodge.arrow.trianglepath.fill")
                            .font(.system(size: 48))
                            .foregroundStyle(.green)
                        Text("Connect Home Assistant")
                            .font(.title2.bold())
                        Text("Enter your Home Assistant URL and a Long-Lived Access Token to begin.")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                            .multilineTextAlignment(.center)
                    }

                    VStack(spacing: 16) {
                        VStack(alignment: .leading, spacing: 6) {
                            Text("Instance Name")
                                .font(.caption.bold())
                                .foregroundStyle(.secondary)
                            TextField("Home", text: $instanceName)
                                .textFieldStyle(.roundedBorder)
                                .textContentType(.name)
                        }

                        VStack(alignment: .leading, spacing: 6) {
                            Text("Home Assistant URL")
                                .font(.caption.bold())
                                .foregroundStyle(.secondary)
                            TextField("http://homeassistant.local:8123", text: $haURL)
                                .textFieldStyle(.roundedBorder)
                                .keyboardType(.URL)
                                .textContentType(.URL)
                                .autocorrectionDisabled()
                                .textInputAutocapitalization(.never)
                        }

                        VStack(alignment: .leading, spacing: 6) {
                            Text("Long-Lived Access Token")
                                .font(.caption.bold())
                                .foregroundStyle(.secondary)
                            SecureField("Enter your HA token", text: $haToken)
                                .textFieldStyle(.roundedBorder)
                                .autocorrectionDisabled()
                                .textInputAutocapitalization(.never)
                            Text("Create one in HA: Profile → Long-Lived Access Tokens → Create Token")
                                .font(.caption2)
                                .foregroundStyle(.secondary)
                        }
                    }

                    if let error = errorMessage {
                        Text(error)
                            .font(.caption)
                            .foregroundStyle(.red)
                            .frame(maxWidth: .infinity, alignment: .leading)
                    }

                    VStack(spacing: 12) {
                        Button {
                            Task { await connect() }
                        } label: {
                            HStack {
                                if isConnecting {
                                    ProgressView()
                                        .tint(.white)
                                }
                                Text(isConnecting ? "Connecting…" : "Authorize")
                                    .font(.headline)
                            }
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(canConnect ? Color.accentColor : Color.gray)
                            .foregroundStyle(.white)
                            .clipShape(RoundedRectangle(cornerRadius: 12))
                        }
                        .disabled(!canConnect || isConnecting)

                        Button {
                            scanNetwork()
                        } label: {
                            Label("Scan Network", systemImage: "wifi")
                                .font(.subheadline)
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(Color(.secondarySystemBackground))
                                .clipShape(RoundedRectangle(cornerRadius: 12))
                        }
                    }
                }
                .padding()
                .frame(maxWidth: 600)
                .frame(maxWidth: .infinity)
            }
            .background(Color(.systemBackground))
            .navigationTitle("Setup")
            .navigationDestination(isPresented: $showDiscovery) {
                EntityDiscoveryView(onComplete: {
                    env.completeOnboarding()
                })
            }
        }
    }

    private var canConnect: Bool {
        !haURL.isEmpty && !haToken.isEmpty && !instanceName.isEmpty
    }

    private func connect() async {
        isConnecting = true
        errorMessage = nil

        env.connectionManager.addInstance(name: instanceName, url: haURL, token: haToken)
        await env.connectionManager.connect()

        try? await Task.sleep(nanoseconds: 2_000_000_000)

        if env.connectionManager.connectionState.isConnected {
            HapticManager.success()
            showDiscovery = true
        } else {
            errorMessage = "Failed to connect. Check URL and token."
            HapticManager.warning()
        }
        isConnecting = false
    }

    private func scanNetwork() {
        haURL = "http://homeassistant.local:8123"
        HapticManager.light()
    }
}
