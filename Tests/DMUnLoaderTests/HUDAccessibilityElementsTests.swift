//
//  DMUnLoader
//
//  Created by Mykola Dementiev
//

import XCTest

/// The accessibility elements that the HUD window hands out in each state, in order, with their label,
/// value and traits, in the card of every release so far and in the accessible card at the largest
/// accessibility text size.
///
/// This is what VoiceOver walks, as far as a test can see it: the order is the one of the container API
/// that VoiceOver asks the hosting view for, and each test also holds that it is the reading order.
/// VoiceOver does not run on the Simulator, so the order it actually takes is not observed.
///
/// Each list pins today's behaviour, so that a later change of a label, a trait or the order reads as a
/// deliberate change and not as a regression.
@MainActor
final class HUDAccessibilityElementsTests: XCTestCase {
    private let loadingText = "label=\"Loading...\" value=nil traits=staticText"
    private let loadingIndicator = "label=nil value=nil traits=updatesFrequently"
    private let successText = "label=\"Saved\" value=nil traits=staticText"
    private let failureTitle = "label=\"An error has occurred!\" value=nil traits=staticText"
    private let failureMessage = "label=\"The server did not answer.\" value=nil traits=staticText"
    private let closeButton = "label=\"Close\" value=nil traits=button"
    private let retryButton = "label=\"Retry\" value=nil traits=button"

    // MARK: - The card of every release so far

    func test_loading_standardLayout_listsTheTextAndTheIndicator() {
        guard let hud = makeHostedHUD(showing: .loading) else { return }

        XCTAssertEqual(
            hud.signatures,
            [loadingText, loadingIndicator],
            """
            pins today's behaviour: the loading indicator has no label, so assistive technology has \
            nothing to say for it; a label for it would be a deliberate change (recorded as a defect \
            of its own). The value is nil in a hosted window of the package tests; the example app \
            reported "1" for the same indicator on iOS 26.5, so the value depends on the host
            """
        )
        XCTAssertTrue(hud.elements.areInReadingOrder, "the elements stand in reading order, top to bottom")
    }

    func test_success_standardLayout_listsTheMessageOnly() {
        guard let hud = makeHostedHUD(showing: .success) else { return }

        XCTAssertEqual(
            hud.signatures,
            [successText],
            "pins today's behaviour: the message only; the default image of the success is hidden from assistive technology"
        )
        XCTAssertTrue(hud.elements.areInReadingOrder, "the elements stand in reading order, top to bottom")
    }

    func test_failure_standardLayout_listsTheTitleTheMessageAndClose() {
        guard let hud = makeHostedHUD(showing: .failure) else { return }

        XCTAssertEqual(
            hud.signatures,
            [failureTitle, failureMessage, closeButton],
            "pins today's behaviour: the title carries no header trait; Close is the only button"
        )
        XCTAssertTrue(hud.elements.areInReadingOrder, "the elements stand in reading order, top to bottom")
    }

    func test_failureWithRetry_standardLayout_listsCloseBeforeRetry() {
        guard let hud = makeHostedHUD(showing: .failureWithRetry) else { return }

        XCTAssertEqual(
            hud.signatures,
            [failureTitle, failureMessage, closeButton, retryButton],
            "pins today's behaviour: the title carries no header trait; Close comes before Retry"
        )
        XCTAssertTrue(
            hud.elements.areInReadingOrder,
            "Close stands left of Retry on one row, and both stand under the texts"
        )
    }

    // MARK: - The accessible card at the largest accessibility text size

    func test_loading_accessibleLayout_listsTheTextAndTheIndicator() {
        guard let hud = makeHostedHUD(showing: .loading, layout: .accessible) else { return }

        XCTAssertEqual(
            hud.signatures,
            [loadingText, loadingIndicator],
            "pins today's behaviour: the same two elements as the standard card, the indicator without a label"
        )
        XCTAssertTrue(hud.elements.areInReadingOrder, "the elements stand in reading order, top to bottom")
    }

    func test_success_accessibleLayout_listsTheMessageOnly() {
        guard let hud = makeHostedHUD(showing: .success, layout: .accessible) else { return }

        XCTAssertEqual(hud.signatures, [successText], "pins today's behaviour: the message only")
        XCTAssertTrue(hud.elements.areInReadingOrder, "the elements stand in reading order, top to bottom")
    }

    func test_failure_accessibleLayout_listsTheTitleTheMessageAndClose() {
        guard let hud = makeHostedHUD(showing: .failure, layout: .accessible) else { return }

        XCTAssertEqual(
            hud.signatures,
            [failureTitle, failureMessage, closeButton],
            "pins today's behaviour: the title carries no header trait; Close is the only button"
        )
        XCTAssertTrue(hud.elements.areInReadingOrder, "the elements stand in reading order, top to bottom")
    }

    func test_failureWithRetry_accessibleLayout_stacksCloseAboveRetry() {
        guard let hud = makeHostedHUD(showing: .failureWithRetry, layout: .accessible) else { return }
        let close = hud.element(labeled: "Close")
        let retry = hud.element(labeled: "Retry")

        XCTAssertEqual(
            hud.signatures,
            [failureTitle, failureMessage, closeButton, retryButton],
            "pins today's behaviour: the title carries no header trait; Close comes before Retry"
        )
        XCTAssertTrue(hud.elements.areInReadingOrder, "the elements stand in reading order, top to bottom")
        XCTAssertLessThan(
            close?.frame.maxY ?? .infinity,
            retry?.frame.minY ?? 0,
            "at accessibility text sizes Close stands above Retry, not beside it"
        )
    }
}
