import Foundation

class AppSettings: ObservableObject {
    @Published var blockedDomains: [String] {
        didSet { saveDomains() }
    }

    private static let domainsKey = "FocusApp.BlockedDomains"

    static let socialMediaPreset = [
        "twitter.com", "x.com", "reddit.com", "youtube.com",
        "instagram.com", "facebook.com", "tiktok.com",
        "threads.net", "snapchat.com"
    ]

    init() {
        if let saved = UserDefaults.standard.stringArray(forKey: Self.domainsKey) {
            blockedDomains = saved
        } else {
            blockedDomains = []
        }
    }

    func addDomain(_ domain: String) {
        let cleaned = domain
            .trimmingCharacters(in: .whitespacesAndNewlines)
            .lowercased()
            .replacingOccurrences(of: "https://", with: "")
            .replacingOccurrences(of: "http://", with: "")
            .replacingOccurrences(of: "www.", with: "")
            .trimmingCharacters(in: CharacterSet(charactersIn: "/"))

        guard !cleaned.isEmpty, !blockedDomains.contains(cleaned) else { return }
        blockedDomains.append(cleaned)
    }

    func removeDomain(at offsets: IndexSet) {
        blockedDomains.remove(atOffsets: offsets)
    }

    func addSocialMediaPreset() {
        for domain in Self.socialMediaPreset {
            if !blockedDomains.contains(domain) {
                blockedDomains.append(domain)
            }
        }
    }

    private func saveDomains() {
        UserDefaults.standard.set(blockedDomains, forKey: Self.domainsKey)
    }
}
