/// Accessibility identifiers of the demo screen. The app and its UI tests share this file.
enum DemoIdentifier {
    static let contentTaps = "contentTaps"
    static let retries = "retries"
    /// The counters again, in the window that `--counters-window` shows above the HUD.
    static let windowContentTaps = "windowContentTaps"
    static let windowRetries = "windowRetries"
    static let showLoading = "showLoading"
    static let showSuccess = "showSuccess"
    static let showFailure = "showFailure"
    static let content = "content"
    static let cover = "cover"
    /// The elements of the HUD window that assistive technology reaches, which
    /// `--accessibility-tree` shows in the counters window.
    static let hudAccessibilityTree = "hudAccessibilityTree"
    /// The number of HUD windows in the connected scenes, which `--accessibility-tree` shows in the counters window.
    static let hudWindowCount = "hudWindowCount"
    static let constructionWitness = "constructionWitness"
}

/// The texts of the demo screen, so a test compares against the text the app builds.
enum DemoText {
    /// What assistive technology reads for the control under the HUD.
    static let contentLabel = "Content under the HUD"

    /// Fills the control under the HUD, so the dim and the blur of a HUD have something
    /// to show on.
    static let content = String(
        repeating: "This text lies under the HUD. A tap that arrives here is counted above. "
            + "While a HUD is shown, the overlay dims the screen, blurs its middle "
            + "and keeps touches away from this control. ",
        count: 12
    )

    static func contentTaps(_ count: Int) -> String {
        "Content taps: \(count)"
    }

    static func retries(_ count: Int) -> String {
        "Retries: \(count)"
    }

    static func coverTaps(_ count: Int) -> String {
        "Cover taps: \(count)"
    }

    static func hudWindows(_ count: Int) -> String {
        "HUD windows: \(count)"
    }

    static func delegateHoldsTheManager(_ held: Bool) -> String {
        "Delegate holds the manager: \(held ? "yes" : "no")"
    }

    /// Between two elements of the HUD in the accessibility tree that the counters window shows.
    static let treeSeparator = " | "
    /// After the label of an element of that tree that is an image.
    static let imageMark = " (image)"

    /// The texts of the HUD with `--host-texts`, in place of the library's defaults.
    enum Host {
        static let title = "Something broke"
        static let close = "Dismiss"
        static let retry = "Try again"
        static let loading = "Hold on"
        /// The system symbol of the host's failure image, with `--host-image`.
        static let image = "wifi.exclamationmark"
    }
}
