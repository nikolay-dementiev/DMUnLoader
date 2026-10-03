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
    /// `--injected` starts the SwiftUI app without the library's app delegate: the app owns
    /// its `DMLoadingManagerMain` and gives it to `DMRootLoadingView(manager:content:)`.
    let injectsManager: Bool
    /// `--auto-hide <seconds>` changes how long a success or a failure stays on screen.
    /// Only the SwiftUI launch with `DMLoadingManagerMain` reads it: the UIKit scene delegate
    /// creates its own manager, and `StickyLoadingManager` has no timer.
    let autoHideDelay: Duration?
    /// `--loading-duration <seconds>` changes how long the simulated work takes.
    let loadingDuration: Duration
    /// `--initial-failure`, with `--auto-hide`, starts with a failure that the manager holds
    /// before the HUD window exists.
    let startsWithFailure: Bool
    /// `--retry-counts-only` makes Retry count the retry and leave the failure on screen,
    /// instead of starting the work again, so a test sees what Retry does to the HUD itself.
    let retryCountsOnly: Bool
    /// `--failure-with-retry-waits`, with `--auto-hide`, gives a failure with Retry the rule
    /// "never hides by itself, and a tap on its card keeps it".
    let failureWithRetryWaits: Bool
    /// `--cover-after-hud` shows a window of the host, a cover at the normal level, a second
    /// after a failure HUD appears.
    let coverAfterHUD: Bool
    /// `--hud-above-normal`, with `--auto-hide`, puts the HUD window at `.normal + 1`.
    let hudAboveNormal: Bool
    /// `--backdrop dim|dim-clear|material|clear`, with `--auto-hide`, chooses the backdrop of the
    /// HUD, `dim-clear` being a dim of a clear colour; without it the HUD keeps the variable blur.
    let backdrop: String?

    init(arguments: [String]) {
        integration = arguments.contains("--uikit") ? .uiKit : .swiftUI
        usesCustomManager = arguments.contains("--custom-manager")
        injectsManager = arguments.contains("--injected")
        autoHideDelay = Self.seconds(after: "--auto-hide", in: arguments)
        loadingDuration = Self.seconds(after: "--loading-duration", in: arguments) ?? .seconds(3)
        startsWithFailure = arguments.contains("--initial-failure")
        retryCountsOnly = arguments.contains("--retry-counts-only")
        failureWithRetryWaits = arguments.contains("--failure-with-retry-waits")
        coverAfterHUD = arguments.contains("--cover-after-hud")
        hudAboveNormal = arguments.contains("--hud-above-normal")
        backdrop = arguments.firstIndex(of: "--backdrop").flatMap { index in
            arguments.indices.contains(index + 1) ? arguments[index + 1] : nil
        }
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
