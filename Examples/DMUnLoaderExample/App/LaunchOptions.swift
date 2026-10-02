import Foundation

/// How this run of the example was asked to start.
struct LaunchOptions: Sendable {
    enum Integration: Sendable {
        /// `DMAppDelegate` and `DMRootLoadingView` in a SwiftUI app.
        case swiftUI
        /// `DMSceneDelegateUIKit` in a UIKit app.
        case uiKit
    }

    static let current = LaunchOptions(arguments: ProcessInfo.processInfo.arguments)

    /// `--uikit` selects the UIKit integration.
    let integration: Integration
    /// `--custom-manager` replaces `DMLoadingManagerMain` with `StickyLoadingManager`.
    let usesCustomManager: Bool
    /// `--auto-hide <seconds>` changes how long a success or a failure stays on screen.
    let autoHideDelay: Duration?
    /// `--loading-duration <seconds>` changes how long the simulated work takes.
    let loadingDuration: Duration

    init(arguments: [String]) {
        integration = arguments.contains("--uikit") ? .uiKit : .swiftUI
        usesCustomManager = arguments.contains("--custom-manager")
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
