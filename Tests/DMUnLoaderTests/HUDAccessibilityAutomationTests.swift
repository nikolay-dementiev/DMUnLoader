//
//  DMUnLoader
//
//  Created by Mykola Dementiev
//

import XCTest

/// The switch that the accessibility tests of the HUD stand on: SwiftUI builds the accessibility tree
/// of the HUD only while the automation service is on. If a system drops the switch, these tests and
/// every test that reads the tree fail with a message that names it; none of them skips.
@MainActor
final class HUDAccessibilityAutomationTests: XCTestCase {

    // MARK: - The switch gives the tree

    func test_automation_turnedOn_givesAHostedHUDItsAccessibilityTree() {
        guard let sut = makeSUT() else { return }

        XCTAssertEqual(
            sut.elements.compactMap(\.label),
            ["An error has occurred!", "The server did not answer.", "Close", "Retry"],
            "with the automation on, the HUD window hands out its elements; without it the tree stays empty"
        )
    }

    // MARK: - On and off

    func test_automation_turnedOnAndOffAgain_isReportedBySystem() {
        guard turnOnAccessibilityAutomation() else { return }
        // The system takes the switch to its accessibility service and answers a little later, so the
        // state it reports is waited for, not read at once.
        XCTAssertTrue(
            turnRunLoop(until: AccessibilityAutomation.isOn() == true),
            "the system reports the automation on after the switch"
        )

        AccessibilityAutomation.turnOff()

        XCTAssertTrue(
            turnRunLoop(until: AccessibilityAutomation.isOn() == false),
            "the system reports the automation off after it is switched off"
        )
    }

    func test_turnOnAccessibilityAutomation_whenTheTestEnds_leavesTheSystemWithTheAutomationOff() {
        // Teardown blocks run last to first, so this one, added first, runs after the one that
        // turnOnAccessibilityAutomation adds, and sees the state that the system is left in.
        addTeardownBlock { [self] in
            XCTAssertTrue(
                turnRunLoop(until: AccessibilityAutomation.isOn() == false),
                "the system reports the automation off once the test has ended"
            )
        }

        guard turnOnAccessibilityAutomation() else { return }

        XCTAssertTrue(
            turnRunLoop(until: AccessibilityAutomation.isOn() == true),
            "the system reports the automation on while the test runs"
        )
    }

    // MARK: - A system that does not offer the switch

    func test_automation_whenTheLibraryIsMissing_failsWithAMessageThatNamesTheSwitch() {
        let reason = AccessibilityAutomation.turnOn(libraryPath: "/nonexistent/library.dylib")

        XCTAssertNotNil(reason, "a system without the switch is a failure to switch on, not a pass and not a crash")
        XCTAssertTrue(
            reason?.contains("accessibility automation cannot be switched on") == true,
            "the message says what failed: \(reason ?? "no message")"
        )
        XCTAssertTrue(
            reason?.contains(AccessibilityAutomation.setterName) == true,
            "the message names the function that is the switch: \(reason ?? "no message")"
        )
        XCTAssertTrue(
            reason?.contains("fails and does not skip") == true,
            "the message says the test fails and does not skip: \(reason ?? "no message")"
        )
    }

    func test_automation_whenTheLibraryHasNoSuchFunction_failsWithAMessageThatNamesTheFunctionAskedFor() {
        let reason = AccessibilityAutomation.turnOn(setterName: "no_such_function_for_the_test")

        XCTAssertTrue(
            reason?.contains("has no function no_such_function_for_the_test") == true,
            "a library that lacks the function is a failure to switch on: \(reason ?? "no message")"
        )
    }

    func test_automation_whenTheLibraryIsMissing_turnOffAndIsOnSayTheyCannotTell() {
        XCTAssertNotNil(
            AccessibilityAutomation.turnOff(libraryPath: "/nonexistent/library.dylib"),
            "switching off through a library that is missing reports why it could not"
        )
        XCTAssertNil(
            AccessibilityAutomation.isOn(libraryPath: "/nonexistent/library.dylib"),
            "a library that is missing cannot tell the state"
        )
    }

    func test_turnOnAccessibilityAutomation_whenTheSystemOffersNoSwitch_reportsOneFailureAndReturnsFalse() {
        var reported: [String] = []

        let turnedOn = turnOnAccessibilityAutomation(
            libraryPath: "/nonexistent/library.dylib",
            report: { reason, _, _ in reported.append(reason) }
        )

        XCTAssertFalse(turnedOn, "the caller is told that the automation is not on, so it returns")
        XCTAssertEqual(reported.count, 1, "a system without the switch is reported once, as a failure: \(reported)")
        XCTAssertTrue(
            reported.first?.contains("fails and does not skip") == true,
            "the report says that the test fails and does not skip: \(reported)"
        )
    }

    // MARK: - Helpers

    private func makeSUT(file: StaticString = #filePath, line: UInt = #line) -> HostedHUD? {
        makeHostedHUD(showing: .failureWithRetry, file: file, line: line)
    }
}
