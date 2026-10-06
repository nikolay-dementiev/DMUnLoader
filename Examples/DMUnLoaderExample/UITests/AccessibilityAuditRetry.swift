import XCTest

@MainActor
func performAccessibilityAuditRetryingTimeouts(_ audit: () throws -> Void) throws {
    try audit()
}
