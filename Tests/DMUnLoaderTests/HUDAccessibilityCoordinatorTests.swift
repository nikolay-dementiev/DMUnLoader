//
//  DMUnLoader
//
//  Created by Mykola Dementiev
//

import XCTest
import DMUnLoader

/// What the HUD tells assistive technology as its phase changes, and when the content
/// underneath is hidden and shown again. One spy records both, in order.
@MainActor
final class HUDAccessibilityCoordinatorTests: XCTestCase {

    func test_hudAppears_remembersFocusHidesContentThenPostsScreenChanged() {
        let (sut, spy) = makeSUT()

        sut.phaseDidChange(to: .loading)

        XCTAssertEqual(spy.events, [.readFocus, .hide, .screenChanged(focusing: nil)])
    }

    func test_phaseChangesWhileShown_postsScreenChanged() {
        let (sut, spy) = makeSUT()
        sut.phaseDidChange(to: .loading)
        let eventsOfTheEntry = spy.events

        sut.phaseDidChange(to: .failureWithRetry)

        XCTAssertEqual(
            spy.events,
            eventsOfTheEntry + [.screenChanged(focusing: nil)],
            "the new card is read from its first element, and the content stays hidden with no second hide"
        )
    }

    func test_hudGoes_restoresContentThenFocusesTheRememberedElement() {
        let (sut, spy) = makeSUT()
        let element = NSObject()
        spy.focused = element
        sut.phaseDidChange(to: .success)

        sut.phaseDidChange(to: .none)

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
        sut.phaseDidChange(to: .failure)
        spy.focusedElementIsOnScreen = false

        sut.phaseDidChange(to: .none)

        XCTAssertEqual(spy.events.last, .screenChanged(focusing: nil), "an element no longer on screen gets no focus")
    }

    func test_presenterDismissedWhileShown_restoresContent() {
        let (sut, spy) = makeSUT()
        sut.phaseDidChange(to: .failure)

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
        sut.phaseDidChange(to: .loading)

        // A new manager that shows nothing takes over the HUD window.
        sut.phaseDidChange(to: .none)

        XCTAssertEqual(spy.events.filter { $0 == .restore }.count, 1, "the content comes back with the idle manager")
    }

    func test_sameStateTwice_postsNothing() {
        let (sut, spy) = makeSUT()
        sut.phaseDidChange(to: .loading)
        let eventsAfterTheFirst = spy.events

        sut.phaseDidChange(to: .loading)

        XCTAssertEqual(spy.events, eventsAfterTheFirst, "the same phase again tells nothing")
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
