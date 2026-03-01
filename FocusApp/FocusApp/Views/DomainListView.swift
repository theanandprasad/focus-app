import SwiftUI

struct DomainListView: View {
    @EnvironmentObject var appState: AppState
    @State private var newDomain = ""

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Blocked Sites")
                .font(.subheadline)
                .foregroundColor(.secondary)

            // Add domain input
            HStack {
                TextField("e.g. reddit.com", text: $newDomain)
                    .textFieldStyle(.roundedBorder)
                    .onSubmit { addDomain() }

                Button("Add") { addDomain() }
                    .disabled(newDomain.trimmingCharacters(in: .whitespaces).isEmpty)
            }

            // Social media preset
            if !hasAllSocialMedia {
                Button("+ Add Social Media Bundle") {
                    appState.settings.addSocialMediaPreset()
                }
                .buttonStyle(.plain)
                .foregroundColor(.accentColor)
                .font(.caption)
            }

            // Domain list
            if appState.settings.blockedDomains.isEmpty {
                Text("No sites added yet")
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .frame(maxWidth: .infinity, alignment: .center)
                    .padding(.vertical, 8)
            } else {
                ScrollView {
                    VStack(spacing: 2) {
                        ForEach(appState.settings.blockedDomains, id: \.self) { domain in
                            HStack {
                                Text(domain)
                                    .font(.system(.body, design: .monospaced))
                                Spacer()
                                Button {
                                    if let index = appState.settings.blockedDomains.firstIndex(of: domain) {
                                        appState.settings.removeDomain(at: IndexSet(integer: index))
                                    }
                                } label: {
                                    Image(systemName: "xmark.circle.fill")
                                        .foregroundColor(.secondary)
                                }
                                .buttonStyle(.plain)
                            }
                            .padding(.vertical, 2)
                            .padding(.horizontal, 4)
                        }
                    }
                }
                .frame(maxHeight: 120)
            }
        }
    }

    private var hasAllSocialMedia: Bool {
        AppSettings.socialMediaPreset.allSatisfy {
            appState.settings.blockedDomains.contains($0)
        }
    }

    private func addDomain() {
        appState.settings.addDomain(newDomain)
        newDomain = ""
    }
}
