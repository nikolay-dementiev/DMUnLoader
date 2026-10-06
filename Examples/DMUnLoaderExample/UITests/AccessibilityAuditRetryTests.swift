import XCTest

/// The retry of an accessibility audit. The audit is a closure here, so these tests run
/// without the app. The timeout is the error that the hosted runners reported.
@MainActor
final class AccessibilityAuditRetryTests: XCTestCase {
    private let timeout = NSError(domain: "com.apple.xcode.xctest.accessibilityAudit", code: -56)
    private let timeoutWithAnotherCode = NSError(domain: "com.apple.xcode.xctest.accessibilityAudit", code: -1)
    private let otherError = NSError(domain: "Test", code: 7)

    func test_audit_twoTimeoutsThenSuccess_passesAfterThreeCalls() throws {
        var calls = 0

        try performAccessibilityAuditRetryingTimeouts {
            calls += 1
            if calls < 3 {
                throw timeout
            }
        }

        XCTAssertEqual(calls, 3, "the audit runs again after each of its two timeouts and passes on the third call")
    }

    func test_audit_threeTimeouts_throwsTheTimeoutAfterThreeCalls() {
        var calls = 0

        XCTAssertThrowsError(
            try performAccessibilityAuditRetryingTimeouts {
                calls += 1
                throw timeout
            },
            "the timeout of the third attempt is thrown"
        ) { error in
            XCTAssertEqual((error as NSError).code, -56, "the error thrown is the timeout of the last attempt")
        }
        XCTAssertEqual(calls, 3, "three attempts in all and no fourth")
    }

    func test_audit_otherError_throwsAtOnceWithoutARetry() {
        var calls = 0

        XCTAssertThrowsError(
            try performAccessibilityAuditRetryingTimeouts {
                calls += 1
                throw otherError
            },
            "an error that is not the timeout is thrown"
        )
        XCTAssertEqual(calls, 1, "an error that is not the timeout is not retried")
    }

    func test_audit_timeoutDomainWithAnotherCode_throwsAtOnceWithoutARetry() {
        var calls = 0

        XCTAssertThrowsError(
            try performAccessibilityAuditRetryingTimeouts {
                calls += 1
                throw timeoutWithAnotherCode
            },
            "an error of the audit domain with another code is thrown"
        )
        XCTAssertEqual(calls, 1, "only the timeout code is retried, not every error of the audit domain")
    }

    func test_audit_passes_runsOnce() throws {
        var calls = 0

        try performAccessibilityAuditRetryingTimeouts {
            calls += 1
        }

        XCTAssertEqual(calls, 1, "an audit that passes is run once")
    }
}
