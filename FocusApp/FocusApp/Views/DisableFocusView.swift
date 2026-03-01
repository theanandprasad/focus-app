import SwiftUI

struct DisableFocusView: View {
    @EnvironmentObject var appState: AppState
    @Binding var isPresented: Bool
    @State private var challengePhrase = ""
    @State private var userInput = ""
    @State private var showError = false

    var body: some View {
        VStack(spacing: 16) {
            Text("Emergency Stop")
                .font(.title2)
                .fontWeight(.bold)

            Text("To disable focus mode early, type the following phrase exactly:")
                .font(.subheadline)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)

            Text(challengePhrase)
                .font(.system(.body, design: .monospaced))
                .padding(12)
                .background(Color.secondary.opacity(0.1))
                .cornerRadius(8)
                .textSelection(.enabled)

            TextField("Type the phrase here...", text: $userInput)
                .textFieldStyle(.roundedBorder)
                .font(.system(.body, design: .monospaced))

            if showError {
                Text("Phrase doesn't match. Try again with the new phrase.")
                    .font(.caption)
                    .foregroundColor(.red)
            }

            HStack(spacing: 12) {
                Button("Cancel") {
                    isPresented = false
                }
                .buttonStyle(.bordered)

                Button("Confirm Stop") {
                    if appState.attemptEarlyStop(typedPhrase: userInput, challenge: challengePhrase) {
                        isPresented = false
                    } else {
                        showError = true
                        userInput = ""
                        // Regenerate phrase on failure
                        challengePhrase = appState.phraseGenerator.generate()
                    }
                }
                .buttonStyle(.borderedProminent)
                .tint(.orange)
                .disabled(userInput.isEmpty)
            }
        }
        .padding(24)
        .frame(width: 420)
        .onAppear {
            challengePhrase = appState.phraseGenerator.generate()
        }
    }
}
