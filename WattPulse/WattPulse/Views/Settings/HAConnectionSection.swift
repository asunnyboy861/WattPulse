import SwiftUI

struct HAConnectionSection: View {
    @EnvironmentObject private var env: AppEnvironment
    @State private var showingAddInstance: Bool = false
    @State private var newInstanceName: String = ""
    @State private var newURL: String = ""
    @State private var newToken: String = ""

    var body: some View {
        Section {
            if env.connectionManager.instances.isEmpty {
                Text("No HA instance configured")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            } else {
                ForEach(env.connectionManager.instances) { instance in
                    instanceRow(instance)
                }
            }

            Button {
                showingAddInstance.toggle()
            } label: {
                Label("Add Another HA Instance", systemImage: "plus.circle")
            }
        } header: {
            Text("Home Assistant")
        }
        .sheet(isPresented: $showingAddInstance) {
            addInstanceSheet
        }
    }

    private func instanceRow(_ instance: HAInstance) -> some View {
        HStack {
            VStack(alignment: .leading, spacing: 2) {
                Text(instance.name)
                    .font(.subheadline.bold())
                Text(instance.url)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            Spacer()
            if env.connectionManager.activeInstanceId == instance.id {
                Image(systemName: "checkmark.circle.fill")
                    .foregroundStyle(.green)
            }
        }
        .contentShape(Rectangle())
        .onTapGesture {
            env.connectionManager.switchToInstance(instance)
        }
        .swipeActions {
            Button(role: .destructive) {
                env.connectionManager.removeInstance(instance)
            } label: {
                Label("Delete", systemImage: "trash")
            }
        }
    }

    private var addInstanceSheet: some View {
        NavigationStack {
            Form {
                Section("Instance Details") {
                    TextField("Name", text: $newInstanceName)
                    TextField("URL (http://...)", text: $newURL)
                        .keyboardType(.URL)
                        .autocorrectionDisabled()
                        .textInputAutocapitalization(.never)
                    SecureField("Access Token", text: $newToken)
                        .autocorrectionDisabled()
                        .textInputAutocapitalization(.never)
                }
            }
            .navigationTitle("Add HA Instance")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        clearFields()
                        showingAddInstance = false
                    }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Add") {
                        env.connectionManager.addInstance(name: newInstanceName, url: newURL, token: newToken)
                        clearFields()
                        showingAddInstance = false
                    }
                    .disabled(newInstanceName.isEmpty || newURL.isEmpty || newToken.isEmpty)
                }
            }
        }
    }

    private func clearFields() {
        newInstanceName = ""
        newURL = ""
        newToken = ""
    }
}
