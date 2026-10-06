import XCTest

/// The retry of an accessibility audit. The audit is a closure here, so these tests run
/// without the app. The timeout is the error that the hosted runners reported.
@MainActor
final class AccessibilityAuditRetryTests: XCTestCase {
    private let timeout = NSError(domain: "com.apple.xcode.xctest.accessibilityAudit", code: -56)
    private let timeoutWithAnotherCode = NSError(domain: "com.apple.xcode.xctest.accessibilityAudit", code: -1)
    private let otherError = NSError(domain: "Test", code: 7)

    func test_audit_twoTimeoutsThenSuccess_passesAfterThreeCalls() throws {
        let sut = makeSUT(throwing: [timeout, timeout])

        try performAccessibilityAuditRetryingTimeouts(sut.run)

        XCTAssertEqual(sut.calls(), 3, "the audit runs again after each of its two timeouts and passes on the third call")
    }

    func test_audit_threeTimeouts_throwsTheTimeoutAfterThreeCalls() {
        let sut = makeSUT(throwing: [timeout, timeout, timeout])

        XCTAssertThrowsError(
            try performAccessibilityAuditRetryingTimeouts(sut.run),
            "the timeout of the third attempt is thrown"
        ) { error in
            XCTAssertEqual((error as NSError).code, -56, "the error thrown is the timeout of the last attempt")
        }
        XCTAssertEqual(sut.calls(), 3, "three attempts in all and no fourth")
    }

    func test_audit_otherError_throwsAtOnceWithoutARetry() {
        let sut = makeSUT(throwing: [otherError, otherError, otherError])

        XCTAssertThrowsError(
            try performAccessibilityAuditRetryingTimeouts(sut.run),
            "an error that is not the timeout is thrown"
        )
        XCTAssertEqual(sut.calls(), 1, "an error that is not the timeout is not retried")
    }

    func test_audit_timeoutDomainWithAnotherCode_throwsAtOnceWithoutARetry() {
        let sut = makeSUT(throwing: [timeoutWithAnotherCode, timeoutWithAnotherCode, timeoutWithAnotherCode])

        XCTAssertThrowsError(
            try performAccessibilityAuditRetryingTimeouts(sut.run),
            "an error of the audit domain with another code is thrown"
        )
        XCTAssertEqual(sut.calls(), 1, "only the timeout code is retried, not every error of the audit domain")
    }

    func test_audit_passes_runsOnce() throws {
        let sut = makeSUT(throwing: [])

        try performAccessibilityAuditRetryingTimeouts(sut.run)

        XCTAssertEqual(sut.calls(), 1, "an audit that passes is run once")
    }

    /// The audit under test. It throws `errors`, one per call, and passes once they are used up.
    /// `calls` tells how many times it has run.
    private func makeSUT(throwing errors: [any Error]) -> (run: () throws -> Void, calls: () -> Int) {
        var calls = 0
        return (
            run: {
                calls += 1
                if calls <= errors.count {
                    throw errors[calls - 1]
                }
            },
            calls: { calls }
        )
    }
}
