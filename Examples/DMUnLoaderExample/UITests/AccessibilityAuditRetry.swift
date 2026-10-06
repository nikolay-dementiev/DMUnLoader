import XCTest

/// The timeout of an accessibility audit, and how many times an audit is attempted.
enum AccessibilityAuditRetry {
    /// The attempts of one audit in all, the first one included.
    static let maximumAttempts = 3

    /// Whether `error` is the timeout of an audit. The result bundles of hosted runs show an audit
    /// that stopped with "Audit failed to complete in time" after about 15 and about 25 seconds, on
    /// iOS 18.6 and iOS 26.5. The error has the domain `com.apple.xcode.xctest.accessibilityAudit`
    /// and the code -56.
    static func isTimeout(_ error: any Error) -> Bool {
        let error = error as NSError
        return error.domain == "com.apple.xcode.xctest.accessibilityAudit" && error.code == -56
    }
}

/// Runs `audit` again when, and only when, it throws the timeout of an accessibility audit, and
/// at most `AccessibilityAuditRetry.maximumAttempts` times in all. Any other error is thrown at
/// once. An issue that the audit reports goes to its issue handler and is not retried: the audit
/// does not throw for an issue.
@MainActor
func performAccessibilityAuditRetryingTimeouts(_ audit: () throws -> Void) throws {
    var attempt = 1
    while true {
        do {
            try audit()
            return
        } catch let error where AccessibilityAuditRetry.isTimeout(error) && attempt < AccessibilityAuditRetry.maximumAttempts {
            // Recorded, so that a run which needed a retry says so in its report instead of passing silently.
            let note = "the audit stopped at its timeout on attempt \(attempt) of \(AccessibilityAuditRetry.maximumAttempts)"
            XCTContext.runActivity(named: note) { _ in }
            attempt += 1
        }
    }
}
