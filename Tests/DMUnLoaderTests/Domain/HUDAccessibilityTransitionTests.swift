//
//  DMUnLoader
//
//  Created by Mykola Dementiev
//

import XCTest
import DMUnLoader

/// What assistive technology is told when the phase of a HUD changes: a HUD appeared, its
/// content changed, it went, or nothing. Every cell of the table of phases is checked.
final class HUDAccessibilityTransitionTests: XCTestCase {
    private let shownPhases: [HUDPhase] = [.loading, .success, .failure, .failureWithRetry]

    func test_accessibilityTransition_intoAShownPhase_isEntered() {
        for phase in shownPhases {
            XCTAssertEqual(HUDAccessibilityTransition(from: .none, to: phase), .entered, "none to \(phase)")
        }
    }

    func test_accessibilityTransition_outOfAShownPhase_isLeft() {
        for phase in shownPhases {
            XCTAssertEqual(HUDAccessibilityTransition(from: phase, to: .none), .left, "\(phase) to none")
        }
    }

    func test_accessibilityTransition_betweenTwoShownPhases_isContentChanged() {
        for previous in shownPhases {
            for next in shownPhases where next != previous {
                XCTAssertEqual(
                    HUDAccessibilityTransition(from: previous, to: next),
                    .contentChanged,
                    "\(previous) to \(next)"
                )
            }
        }
    }

    func test_accessibilityTransition_withinOnePhase_isNothing() {
        for phase in [HUDPhase.none] + shownPhases {
            XCTAssertEqual(HUDAccessibilityTransition(from: phase, to: phase), .nothing, "\(phase) to \(phase)")
        }
    }
}
