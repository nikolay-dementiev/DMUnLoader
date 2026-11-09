//
//  DMUnLoader
//
//  Created by Mykola Dementiev
//

import XCTest
import DMUnLoader

/// The reporter of the state of a HUD: what a state that follows another one makes the coordinator
/// announce, seen through a coordinator that tells an announcer which records it.
@MainActor
final class HUDStateReporterTests: XCTestCase {

    func test_report_aHUDThatAppears_isEnteredOnce() {
        let (sut, announcer) = makeSUT()

        sut.report(Self.success("Saved"))

        XCTAssertEqual(
            announcer.events,
            [.readFocus, .hide, .screenChanged(focusing: nil)],
            "a HUD that appears hides the content under it and announces the screen, once"
        )
    }

    func test_report_anotherStateInTheSamePhase_announcesTheScreenAgain() {
        let (sut, announcer) = makeSUT()

        sut.report(Self.failure(Failure.first))
        sut.report(Self.failure(Failure.second))

        XCTAssertEqual(
            announcer.events,
            [.readFocus, .hide, .screenChanged(focusing: nil), .screenChanged(focusing: nil)],
            "another error in the same phase is another content, and the screen is announced again"
        )
    }

    func test_report_theSameStateAgain_announcesNothingMore() {
        let (sut, announcer) = makeSUT()
        sut.report(Self.success("Saved"))
        let eventsOfTheFirst = announcer.events

        sut.report(Self.success("Saved"))

        XCTAssertEqual(announcer.events, eventsOfTheFirst, "a state equal to the one shown is no change of content")
    }

    func test_report_AThenBThenA_announcesEachChange() {
        let (sut, announcer) = makeSUT()

        sut.report(Self.success("A"))
        sut.report(Self.success("B"))
        sut.report(Self.success("A"))

        XCTAssertEqual(
            announcer.events,
            [.readFocus, .hide, .screenChanged(focusing: nil), .screenChanged(focusing: nil), .screenChanged(focusing: nil)],
            "A after B is a change from the state before it, though it equals the first state"
        )
    }

    func test_hudDidGo_givesTheScreenBack_andTheNextStateEntersAgain() {
        let (sut, announcer) = makeSUT()
        sut.report(Self.success("Saved"))

        sut.hudDidGo()
        sut.report(Self.success("Saved"))

        XCTAssertEqual(
            announcer.events,
            [
                .readFocus, .hide, .screenChanged(focusing: nil),
                .restore, .screenChanged(focusing: nil),
                .readFocus, .hide, .screenChanged(focusing: nil)
            ],
            "the HUD that went gave the screen back, and the same state on a new HUD enters it again"
        )
    }

    // MARK: - Helpers

    private enum Failure: Error {
        case first
        case second
    }

    private static let provider = DefaultDMLoadingViewProvider().eraseToAnyViewProvider()

    private static func success(_ message: String) -> DMLoadableType {
        .success(message, provider: provider)
    }

    private static func failure(_ error: Failure) -> DMLoadableType {
        .failure(error: error, provider: provider, onRetry: nil)
    }

    private func makeSUT() -> (sut: HUDStateReporter, announcer: AccessibilitySpy) {
        let announcer = AccessibilitySpy()
        let coordinator = HUDAccessibilityCoordinator(announcer: announcer, contentHider: announcer)
        return (HUDStateReporter(coordinator: coordinator), announcer)
    }
}
