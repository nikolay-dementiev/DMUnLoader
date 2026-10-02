/// Accessibility identifiers of the demo screen. The app and its UI tests share this file.
enum DemoIdentifier {
    static let contentTaps = "contentTaps"
    static let retries = "retries"
    static let showLoading = "showLoading"
    static let showSuccess = "showSuccess"
    static let showFailure = "showFailure"
    static let content = "content"
}

/// The texts of the two counters, so a test compares against the text the app builds.
enum DemoText {
    static func contentTaps(_ count: Int) -> String {
        "Content taps: \(count)"
    }

    static func retries(_ count: Int) -> String {
        "Retries: \(count)"
    }
}
