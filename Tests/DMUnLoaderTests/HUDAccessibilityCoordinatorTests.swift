//
//  DMUnLoader
//
//  Created by Mykola Dementiev
//

import XCTest
import DMUnLoader

/// What the HUD tells assistive technology as its state changes, and when the content
/// underneath is hidden and shown again. One spy records both, in order.
@MainActor
final class HUDAccessibilityCoordinatorTests: XCTestCase {

    func test_hudAppears_remembersFocusHidesContentThenPostsScreenChanged() {
        let (sut, spy) = makeSUT()

        sut.show(.loading)

        XCTAssertEqual(spy.events, [.readFocus, .hide, .screenChanged(focusing: nil)])
    }

    func test_phaseChangesWhileShown_postsScreenChanged() {
        let (sut, spy) = makeSUT()
        sut.show(.loading)
        let eventsOfTheEntry = spy.events

        sut.show(.failureWithRetry)

        XCTAssertEqual(
            spy.events,
            eventsOfTheEntry + [.screenChanged(focusing: nil)],
            "the new card is read from its first element, and the content stays hidden with no second hide"
        )
    }

    func test_anotherStateInTheSamePhase_postsScreenChanged() {
        let (sut, spy) = makeSUT()
        sut.show(.failure, state: "the first failure")
        let eventsOfTheEntry = spy.events

        sut.show(.failure, state: "another failure")

        XCTAssertEqual(
            spy.events,
            eventsOfTheEntry + [.screenChanged(focusing: nil)],
            "another failure in the place of the first is read from its first element, with no second hide"
        )
    }

    func test_hudGoes_restoresContentThenFocusesTheRememberedElement() {
        let (sut, spy) = makeSUT()
        let element = NSObject()
        spy.focused = element
        sut.show(.success)

        sut.show(.none)

        XCTAssertEqual(
            Array(spy.events.suffix(2)),
            [.restore, .screenChanged(focusing: ObjectIdentifier(element))],
            "the content comes back first, then the focus returns to where it was"
        )
    }

    func test_hudGoes_rememberedElementGone_postsScreenChangedWithoutElement() {
        let (sut, spy) = makeSUT()
        let element = NSObject()
        spy.focused = element
        sut.show(.failure)
        spy.focusedElementIsOnScreen = false

        sut.show(.none)

        XCTAssertEqual(spy.events.last, .screenChanged(focusing: nil), "an element no longer on screen gets no focus")
    }

    func test_presenterDismissedWhileShown_restoresContent() {
        let (sut, spy) = makeSUT()
        sut.show(.failure)

        sut.hudDidGo()

        XCTAssertEqual(spy.events.filter { $0 == .restore }.count, 1, "a HUD removed while shown gives the content back")
    }

    func test_presenterDismissedWhileIdle_doesNothing() {
        let (sut, spy) = makeSUT()

        sut.hudDidGo()

        XCTAssertEqual(spy.events, [], "with no HUD shown there is nothing to give back")
    }

    func test_idleManagerReplacesShownOne_restoresContent() {
        let (sut, spy) = makeSUT()
        sut.show(.loading)

        // A new manager that shows nothing takes over the HUD window.
        sut.show(.none)

        XCTAssertEqual(spy.events.filter { $0 == .restore }.count, 1, "the content comes back with the idle manager")
    }

    func test_sameStateTwice_postsNothing() {
        let (sut, spy) = makeSUT()
        sut.show(.loading)
        let eventsAfterTheFirst = spy.events

        sut.show(.loading)

        XCTAssertEqual(spy.events, eventsAfterTheFirst, "the same state again tells nothing")
    }

    // MARK: - Helpers

    private func makeSUT(
        file: StaticString = #filePath,
        line: UInt = #line
    ) -> (sut: HUDAccessibilityCoordinator, spy: AccessibilitySpy) {
        let spy = AccessibilitySpy()
        let sut = HUDAccessibilityCoordinator(announcer: spy, contentHider: spy)
        trackForMemoryLeaks(sut, file: file, line: line)
        return (sut, spy)
    }
}

private extension HUDAccessibilityCoordinator {
    /// The HUD shows a state of `phase`; the state is the phase's own unless `state` names
    /// another, so two calls with one phase are the same state.
    func show(_ phase: HUDPhase, state: String? = nil) {
        stateDidChange(to: phase, identifiedBy: state ?? "\(phase)")
    }
}
