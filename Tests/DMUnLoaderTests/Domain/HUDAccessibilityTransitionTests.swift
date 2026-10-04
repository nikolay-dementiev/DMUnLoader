//
//  DMUnLoader
//
//  Created by Mykola Dementiev
//

import XCTest
import DMUnLoader

/// What assistive technology is told when the state of a HUD changes: a HUD appeared, its
/// content changed, it went, or nothing. Every cell of the table of phases is checked, and in
/// one phase both another state and the same state.
final class HUDAccessibilityTransitionTests: XCTestCase {
    private let shownPhases: [HUDPhase] = [.loading, .success, .failure, .failureWithRetry]

    func test_accessibilityTransition_intoAShownPhase_isEntered() {
        for phase in shownPhases {
            XCTAssertEqual(
                HUDAccessibilityTransition(from: .none, to: phase, stateChanged: true),
                .entered,
                "none to \(phase)"
            )
        }
    }

    func test_accessibilityTransition_outOfAShownPhase_isLeft() {
        for phase in shownPhases {
            XCTAssertEqual(
                HUDAccessibilityTransition(from: phase, to: .none, stateChanged: true),
                .left,
                "\(phase) to none"
            )
        }
    }

    func test_accessibilityTransition_betweenTwoShownPhases_isContentChanged() {
        for previous in shownPhases {
            for next in shownPhases where next != previous {
                XCTAssertEqual(
                    HUDAccessibilityTransition(from: previous, to: next, stateChanged: true),
                    .contentChanged,
                    "\(previous) to \(next)"
                )
            }
        }
    }

    func test_accessibilityTransition_anotherStateInOneShownPhase_isContentChanged() {
        for phase in shownPhases {
            XCTAssertEqual(
                HUDAccessibilityTransition(from: phase, to: phase, stateChanged: true),
                .contentChanged,
                "\(phase) to another state of \(phase)"
            )
        }
    }

    func test_accessibilityTransition_sameStateInOnePhase_isNothing() {
        for phase in [HUDPhase.none] + shownPhases {
            XCTAssertEqual(
                HUDAccessibilityTransition(from: phase, to: phase, stateChanged: false),
                .nothing,
                "\(phase) to the same state"
            )
        }
    }

    func test_accessibilityTransition_anotherStateWithNoHUD_isNothing() {
        XCTAssertEqual(HUDAccessibilityTransition(from: .none, to: .none, stateChanged: true), .nothing)
    }
}
