import Foundation

enum PrivilegedHelper {
    /// Runs a shell command with admin privileges via AppleScript.
    /// The user will be prompted for their password by macOS.
    static func runWithPrivileges(command: String, completion: @escaping (Bool, String) -> Void) {
        let escapedCommand = command
            .replacingOccurrences(of: "\\", with: "\\\\")
            .replacingOccurrences(of: "\"", with: "\\\"")

        let script = """
        do shell script "\(escapedCommand)" with administrator privileges
        """

        DispatchQueue.global(qos: .userInitiated).async {
            var error: NSDictionary?
            let appleScript = NSAppleScript(source: script)
            let result = appleScript?.executeAndReturnError(&error)

            DispatchQueue.main.async {
                if let error = error {
                    let message = error[NSAppleScript.errorMessage] as? String ?? "Unknown error"
                    completion(false, message)
                } else {
                    completion(true, result?.stringValue ?? "")
                }
            }
        }
    }

    /// Runs a shell command without elevated privileges.
    static func run(command: String, completion: @escaping (Bool, String) -> Void) {
        DispatchQueue.global(qos: .userInitiated).async {
            let process = Process()
            let pipe = Pipe()
            process.standardOutput = pipe
            process.standardError = pipe
            process.launchPath = "/bin/zsh"
            process.arguments = ["-c", command]

            do {
                try process.run()
                process.waitUntilExit()
                let data = pipe.fileHandleForReading.readDataToEndOfFile()
                let output = String(data: data, encoding: .utf8) ?? ""
                DispatchQueue.main.async {
                    completion(process.terminationStatus == 0, output)
                }
            } catch {
                DispatchQueue.main.async {
                    completion(false, error.localizedDescription)
                }
            }
        }
    }
}
