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

    func test_automation_turnedOn_givesAHostedHUDItsAccessibilityTree() {
        guard let hud = makeHostedHUD(showing: .failureWithRetry) else { return }

        XCTAssertEqual(
            hud.elements.compactMap(\.label),
            ["An error has occurred!", "The server did not answer.", "Close", "Retry"],
            "with the automation on, the HUD window hands out its elements; without it the tree stays empty"
        )
    }

    func test_automation_turnedOffAgain_isReportedOffBySystem() {
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

    func test_automation_whenTheSystemOffersNoSwitch_failsWithAMessageThatNamesIt() {
        let reason = AccessibilityAutomation.turnOn(libraryPath: "/nonexistent/library.dylib")

        XCTAssertNotNil(reason, "a system without the switch is a failure to switch on, not a pass and not a crash")
        XCTAssertTrue(
            reason?.contains("accessibility automation cannot be switched on") == true,
            "the message names the automation: \(reason ?? "no message")"
        )
        XCTAssertTrue(
            reason?.contains("fails and does not skip") == true,
            "the message says the test fails and does not skip: \(reason ?? "no message")"
        )
    }
}
