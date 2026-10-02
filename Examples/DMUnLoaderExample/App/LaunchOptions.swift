import Foundation

/// How this run of the example was asked to start.
struct LaunchOptions: Sendable {
    static let current = LaunchOptions(arguments: ProcessInfo.processInfo.arguments)

    /// `--auto-hide <seconds>` changes how long a success or a failure stays on screen.
    let autoHideDelay: Duration?
    /// `--loading-duration <seconds>` changes how long the simulated work takes.
    let loadingDuration: Duration

    init(arguments: [String]) {
        autoHideDelay = Self.seconds(after: "--auto-hide", in: arguments)
        loadingDuration = Self.seconds(after: "--loading-duration", in: arguments) ?? .seconds(3)
    }

    private static func seconds(after flag: String, in arguments: [String]) -> Duration? {
        guard let index = arguments.firstIndex(of: flag),
              arguments.indices.contains(index + 1),
              let value = Double(arguments[index + 1]) else {
            return nil
        }
        return .seconds(value)
    }
}
