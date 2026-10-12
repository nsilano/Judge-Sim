import SwiftUI

/// The player's own Claude API key and model, for live answers from counsel.
struct SettingsView: View {
    @ObservedObject private var settings = AISettings.shared
    @Environment(\.dismiss) private var dismiss
    @State private var keyDraft = ""
    @State private var testState: TestState = .idle

    private enum TestState: Equatable {
        case idle, running, ok, failed(String)
    }

    var body: some View {
        NavigationStack {
            Form {
                Section {
                    if settings.hasKey {
                        Label("API key saved on this iPhone", systemImage: "checkmark.seal.fill")
                            .foregroundStyle(.green)
                        Button("Remove key", role: .destructive) {
                            settings.removeKey()
                            testState = .idle
                        }
                    } else {
                        SecureField("sk-ant-…", text: $keyDraft)
                            .textInputAutocapitalization(.never)
                            .autocorrectionDisabled()
                        Button("Save key") {
                            settings.saveKey(keyDraft)
                            keyDraft = ""
                            testState = .idle
                        }
                        .disabled(keyDraft.trimmingCharacters(in: .whitespaces).isEmpty)
                    }
                } header: {
                    Text("Claude API key")
                } footer: {
                    Text("Create a key at console.anthropic.com (separate from a Claude Pro plan; billed per use). The key stays in this iPhone's Keychain and is only sent to Anthropic. Without a key, counsel answers from the case file.")
                }

                Section {
                    Picker("Model", selection: $settings.model) {
                        ForEach(CounselModel.allCases) { model in
                            Text(model.label).tag(model)
                        }
                    }
                    Text(settings.model.detail).font(.caption).foregroundStyle(.secondary)
                } header: {
                    Text("Counsel model")
                }

                if settings.hasKey {
                    Section {
                        Button {
                            testState = .running
                            Task { @MainActor in
                                do {
                                    try await ClaudeClient.test()
                                    testState = .ok
                                } catch {
                                    testState = .failed(error.localizedDescription)
                                }
                            }
                        } label: {
                            HStack {
                                Text("Test connection")
                                Spacer()
                                switch testState {
                                case .idle: EmptyView()
                                case .running: ProgressView()
                                case .ok: Image(systemName: "checkmark.circle.fill").foregroundStyle(.green)
                                case .failed: Image(systemName: "xmark.octagon.fill").foregroundStyle(.red)
                                }
                            }
                        }
                        .disabled(testState == .running)
                        if case .failed(let message) = testState {
                            Text(message).font(.caption).foregroundStyle(.red)
                        }
                    }
                }

                Section {
                    HStack {
                        Text("Version")
                        Spacer()
                        Text(VersionBadge.text).foregroundStyle(.secondary).monospaced()
                    }
                }
            }
            .navigationTitle("Settings")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Done") { dismiss() }
                }
            }
        }
    }
}
