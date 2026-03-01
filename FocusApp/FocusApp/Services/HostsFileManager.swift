import Foundation

class HostsFileManager {
    private let hostsPath = "/etc/hosts"
    private let markerStart = "# FOCUS_APP_START"
    private let markerEnd = "# FOCUS_APP_END"
    private let unblockScriptPath = "/usr/local/bin/focusapp-unblock"
    private let sudoersPath = "/etc/sudoers.d/focusapp"

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
        let currentUser = NSUserName()

        // Single privileged call that:
        // 1. Blocks domains in /etc/hosts
        // 2. Creates an unblock script
        // 3. Adds a sudoers rule so unblock runs without a password
        let command = """
        /usr/bin/sed '/\(markerStart)/,/\(markerEnd)/d' \(hostsPath) > /tmp/hosts_focus_tmp && \
        /bin/echo '\(entriesToAdd)' >> /tmp/hosts_focus_tmp && \
        /bin/cp /tmp/hosts_focus_tmp \(hostsPath) && \
        /bin/rm /tmp/hosts_focus_tmp && \
        /usr/bin/dscacheutil -flushcache && \
        /usr/bin/killall -HUP mDNSResponder && \
        /bin/cat > \(unblockScriptPath) << 'UNBLOCK_EOF'
        #!/bin/bash
        /usr/bin/sed -i '' '/\(markerStart)/,/\(markerEnd)/d' /etc/hosts
        /usr/bin/dscacheutil -flushcache
        /usr/bin/killall -HUP mDNSResponder
        /bin/rm -f \(unblockScriptPath)
        /bin/rm -f \(sudoersPath)
        UNBLOCK_EOF
        /bin/chmod 755 \(unblockScriptPath) && \
        /bin/echo '\(currentUser) ALL=(ALL) NOPASSWD: \(unblockScriptPath)' > \(sudoersPath) && \
        /bin/chmod 0440 \(sudoersPath)
        """

        PrivilegedHelper.runWithPrivileges(command: command) { success, error in
            if !success {
                print("Failed to block domains: \(error)")
            }
            completion(success)
        }
    }

    func unblockDomains(completion: @escaping (Bool) -> Void) {
        // Uses the sudoers rule set up during blocking — no password needed
        let command = "/usr/bin/sudo \(unblockScriptPath)"

        PrivilegedHelper.run(command: command) { success, error in
            if !success {
                print("Failed to unblock via passwordless sudo: \(error)")
                // Fallback: prompt for password if sudoers rule is missing
                self.unblockWithPrivileges(completion: completion)
                return
            }
            completion(success)
        }
    }

    private func unblockWithPrivileges(completion: @escaping (Bool) -> Void) {
        let command = """
        /usr/bin/sed -i '' '/\(markerStart)/,/\(markerEnd)/d' \(hostsPath) && \
        /usr/bin/dscacheutil -flushcache && \
        /usr/bin/killall -HUP mDNSResponder && \
        /bin/rm -f \(unblockScriptPath) && \
        /bin/rm -f \(sudoersPath)
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
