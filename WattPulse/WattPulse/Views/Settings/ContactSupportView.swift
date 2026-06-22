import SwiftUI

struct ContactSupportView: View {
    @Environment(\.dismiss) private var dismiss

    @State private var selectedSubject: FeedbackSubject = .general
    @State private var customSubject: String = ""
    @State private var name: String = ""
    @State private var email: String = ""
    @State private var message: String = ""
    @State private var isSubmitting: Bool = false
    @State private var submitResult: SubmitResult?

    enum FeedbackSubject: String, CaseIterable, Identifiable {
        case general = "General"
        case feature = "Feature Suggestion"
        case bug = "Bug Report"
        case question = "Usage Question"
        case performance = "Performance Issue"
        case ui = "UI Improvement"
        case other = "Other"

        var id: String { rawValue }
    }

    enum SubmitResult {
        case success
        case failure(String)
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    subjectSection
                    if selectedSubject == .other {
                        customSubjectField
                    }
                    nameField
                    emailField
                    messageField
                    submitButton
                    if let result = submitResult {
                        resultView(result)
                    }
                }
                .padding()
                .frame(maxWidth: 600)
                .frame(maxWidth: .infinity)
            }
            .background(Color(.systemBackground))
            .navigationTitle("Contact Support")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
            }
        }
    }

    private var subjectSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Subject")
                .font(.caption.bold())
                .foregroundStyle(.secondary)
            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 8) {
                ForEach(FeedbackSubject.allCases) { subject in
                    Button {
                        selectedSubject = subject
                        HapticManager.light()
                    } label: {
                        Text(subject.rawValue)
                            .font(.caption.bold())
                            .padding(.horizontal, 12)
                            .padding(.vertical, 10)
                            .frame(maxWidth: .infinity)
                            .background(selectedSubject == subject ? Color.accentColor : Color(.secondarySystemBackground))
                            .foregroundStyle(selectedSubject == subject ? .white : .primary)
                            .clipShape(RoundedRectangle(cornerRadius: 8))
                    }
                    .buttonStyle(.plain)
                }
            }
        }
    }

    private var customSubjectField: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text("Custom Subject")
                .font(.caption.bold())
                .foregroundStyle(.secondary)
            TextField("Specify your topic", text: $customSubject)
                .textFieldStyle(.roundedBorder)
        }
    }

    private var nameField: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text("Name")
                .font(.caption.bold())
                .foregroundStyle(.secondary)
            TextField("Your name", text: $name)
                .textFieldStyle(.roundedBorder)
                .textContentType(.name)
        }
    }

    private var emailField: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text("Email")
                .font(.caption.bold())
                .foregroundStyle(.secondary)
            TextField("you@example.com", text: $email)
                .textFieldStyle(.roundedBorder)
                .keyboardType(.emailAddress)
                .textContentType(.emailAddress)
                .textInputAutocapitalization(.never)
        }
    }

    private var messageField: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text("Message")
                .font(.caption.bold())
                .foregroundStyle(.secondary)
            TextEditor(text: $message)
                .frame(minHeight: 120)
                .padding(8)
                .background(Color(.secondarySystemBackground))
                .clipShape(RoundedRectangle(cornerRadius: 8))
        }
    }

    private var submitButton: some View {
        Button {
            Task { await submit() }
        } label: {
            HStack {
                if isSubmitting {
                    ProgressView().tint(.white)
                }
                Text(isSubmitting ? "Sending…" : "Submit")
                    .font(.headline)
            }
            .frame(maxWidth: .infinity)
            .padding()
            .background(canSubmit ? Color.accentColor : Color.gray)
            .foregroundStyle(.white)
            .clipShape(RoundedRectangle(cornerRadius: 12))
        }
        .disabled(!canSubmit || isSubmitting)
    }

    private var canSubmit: Bool {
        !name.isEmpty && !email.isEmpty && !message.isEmpty && (selectedSubject != .other || !customSubject.isEmpty)
    }

    private func resultView(_ result: SubmitResult) -> some View {
        switch result {
        case .success:
            return AnyView(
                VStack(spacing: 8) {
                    Image(systemName: "checkmark.circle.fill")
                        .font(.title)
                        .foregroundStyle(.green)
                    Text("Thank you! Your feedback has been sent.")
                        .font(.subheadline)
                        .multilineTextAlignment(.center)
                }
                .padding()
                .frame(maxWidth: .infinity)
                .background(Color.green.opacity(0.1))
                .clipShape(RoundedRectangle(cornerRadius: 12))
            )
        case .failure(let error):
            return AnyView(
                VStack(spacing: 8) {
                    Image(systemName: "xmark.circle.fill")
                        .font(.title)
                        .foregroundStyle(.red)
                    Text(error)
                        .font(.subheadline)
                        .multilineTextAlignment(.center)
                }
                .padding()
                .frame(maxWidth: .infinity)
                .background(Color.red.opacity(0.1))
                .clipShape(RoundedRectangle(cornerRadius: 12))
            )
        }
    }

    private var subjectValue: String {
        selectedSubject == .other ? customSubject : selectedSubject.rawValue
    }

    private func submit() async {
        isSubmitting = true
        defer { isSubmitting = false }

        let request = FeedbackRequest(
            name: name,
            email: email,
            subject: subjectValue,
            message: message,
            app_name: AppConfig.appName
        )

        do {
            let url = URL(string: "\(AppConfig.feedbackBackendURL)/api/feedback")!
            var req = URLRequest(url: url)
            req.httpMethod = "POST"
            req.setValue("application/json", forHTTPHeaderField: "Content-Type")
            req.httpBody = try JSONEncoder().encode(request)

            let (_, response) = try await URLSession.shared.data(for: req)
            if let http = response as? HTTPURLResponse, http.statusCode == 200 {
                submitResult = .success
                HapticManager.success()
                try? await Task.sleep(nanoseconds: 1_500_000_000)
                dismiss()
            } else {
                submitResult = .failure("Server error. Please try again later.")
                HapticManager.warning()
            }
        } catch {
            submitResult = .failure("Network error: \(error.localizedDescription)")
            HapticManager.warning()
        }
    }
}

struct FeedbackRequest: Codable {
    let name: String
    let email: String
    let subject: String
    let message: String
    let app_name: String
}
