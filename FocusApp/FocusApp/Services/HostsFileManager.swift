import Foundation

class HostsFileManager {
    private let hostsPath = "/etc/hosts"
    private let markerStart = "# FOCUS_APP_START"
    private let markerEnd = "# FOCUS_APP_END"

    func blockDomains(_ domains: [String], completion: @escaping (Bool) -> Void) {
        var lines = [markerStart]
        for domain in domains {
            lines.append("127.0.0.1 \(domain)")
            if !domain.hasPrefix("www.") {
                lines.append("127.0.0.1 www.\(domain)")
            }
        }
        lines.append(markerEnd)

        let entriesToAdd = lines.joined(separator: "\n")

        // Read current hosts, strip any existing focus entries, append new ones
        let command = """
        /usr/bin/sed '/\(markerStart)/,/\(markerEnd)/d' \(hostsPath) > /tmp/hosts_focus_tmp && \
        /bin/echo '\(entriesToAdd)' >> /tmp/hosts_focus_tmp && \
        /bin/cp /tmp/hosts_focus_tmp \(hostsPath) && \
        /bin/rm /tmp/hosts_focus_tmp && \
        /usr/bin/dscacheutil -flushcache && \
        /usr/bin/killall -HUP mDNSResponder
        """

        PrivilegedHelper.runWithPrivileges(command: command) { success, error in
            if !success {
                print("Failed to block domains: \(error)")
            }
            completion(success)
        }
    }

    func unblockDomains(completion: @escaping (Bool) -> Void) {
        let command = """
        /usr/bin/sed -i '' '/\(markerStart)/,/\(markerEnd)/d' \(hostsPath) && \
        /usr/bin/dscacheutil -flushcache && \
        /usr/bin/killall -HUP mDNSResponder
        """

        PrivilegedHelper.runWithPrivileges(command: command) { success, error in
            if !success {
                print("Failed to unblock domains: \(error)")
            }
            completion(success)
        }
    }

    func isCurrentlyBlocking() -> Bool {
        guard let content = try? String(contentsOfFile: hostsPath, encoding: .utf8) else {
            return false
        }
        return content.contains(markerStart)
    }
}
