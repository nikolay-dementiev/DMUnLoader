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
    private let successText = "label=\"Saved\" value=nil traits=staticText"
    private let failureTitle = "label=\"An error has occurred!\" value=nil traits=staticText"
    private let failureMessage = "label=\"The server did not answer.\" value=nil traits=staticText"
    private let closeButton = "label=\"Close\" value=nil traits=button"
    private let retryButton = "label=\"Retry\" value=nil traits=button"

    // MARK: - The card of every release so far

    func test_loading_standardLayout_listsTheCardAsOneElementNamedByItsText() {
        guard let sut = makeSUT(showing: .loading) else { return }

        XCTAssertEqual(
            sut.signatures,
            [loadingCard(named: "Loading...")],
            """
            the text and the indicator are one element named by the text, with no static text trait, \
            and no value of the indicator: that value depends on the host
            """
        )
        XCTAssertFalse(sut.elements.first?.frame.isEmpty ?? true, "the element has a frame on the screen")
    }

    func test_loading_standardLayout_withACustomText_namesTheElementByThatText() {
        guard let sut = makeSUT(showing: .loading, loadingText: Self.customText) else { return }

        XCTAssertEqual(
            sut.signatures,
            [loadingCard(named: Self.customText)],
            "the element is named by the text the host set, in full"
        )
    }

    func test_loading_standardLayout_withAnEmptyText_namesTheElementByTheDefaultText() {
        guard let sut = makeSUT(showing: .loading, loadingText: "") else { return }

        XCTAssertEqual(
            sut.signatures,
            [loadingCard(named: "Loading...")],
            "the element is named by the default text when the host's text is empty, not left without a name"
        )
    }

    func test_loading_standardLayout_withAWhitespaceOnlyText_namesTheElementByTheDefaultText() {
        guard let sut = makeSUT(showing: .loading, loadingText: " \n") else { return }

        XCTAssertEqual(
            sut.signatures,
            [loadingCard(named: "Loading...")],
            "a text of only whitespace names the element as an empty text does, by the default text"
        )
    }

    func test_success_standardLayout_listsTheMessageOnly() {
        guard let sut = makeSUT(showing: .success) else { return }

        XCTAssertEqual(
            sut.signatures,
            [successText],
            "pins today's behaviour: the message only; the default image of the success is hidden from assistive technology"
        )
        XCTAssertTrue(sut.elements.areInReadingOrder, "the elements stand in reading order, top to bottom")
    }

    func test_failure_standardLayout_listsTheTitleTheMessageAndClose() {
        guard let sut = makeSUT(showing: .failure) else { return }

        XCTAssertEqual(
            sut.signatures,
            [failureTitle, failureMessage, closeButton],
            "pins today's behaviour: the title carries no header trait; Close is the only button"
        )
        XCTAssertTrue(sut.elements.areInReadingOrder, "the elements stand in reading order, top to bottom")
    }

    func test_failureWithRetry_standardLayout_listsCloseBeforeRetryOnOneRow() {
        guard let sut = makeSUT(showing: .failureWithRetry),
              let close = sut.element(labeled: "Close"),
              let retry = sut.element(labeled: "Retry") else { return }

        XCTAssertEqual(
            sut.signatures,
            [failureTitle, failureMessage, closeButton, retryButton],
            "pins today's behaviour: the title carries no header trait; Close comes before Retry"
        )
        XCTAssertTrue(sut.elements.areInReadingOrder, "the elements stand in reading order, top to bottom")
        XCTAssertLessThanOrEqual(
            close.frame.maxX,
            retry.frame.minX,
            "Close stands left of Retry"
        )
        XCTAssertEqual(
            close.frame.minY,
            retry.frame.minY,
            accuracy: 1,
            "Close and Retry stand on one row"
        )
    }

    // MARK: - The accessible card at the largest accessibility text size

    func test_loading_accessibleLayout_listsTheCardAsOneElementAtTheAccessibilitySize() {
        guard let sut = makeSUT(showing: .loading, layout: .accessible) else { return }

        XCTAssertEqual(
            sut.signatures,
            [loadingCard(named: "Loading...")],
            "the same one element as the standard card, named by the text"
        )
        XCTAssertGreaterThan(
            sut.elements.first?.frame.height ?? 0,
            150,
            "the card is drawn at the accessibility size (98 points tall in the standard card)"
        )
    }

    func test_loading_accessibleLayout_withACustomText_namesTheElementByThatText() {
        guard let sut = makeSUT(showing: .loading, layout: .accessible, loadingText: Self.customText) else { return }

        XCTAssertEqual(
            sut.signatures,
            [loadingCard(named: Self.customText)],
            "the element is named by the text the host set, in full"
        )
    }

    func test_loading_accessibleLayout_withAnEmptyText_namesTheElementByTheDefaultText() {
        guard let sut = makeSUT(showing: .loading, layout: .accessible, loadingText: "") else { return }

        XCTAssertEqual(
            sut.signatures,
            [loadingCard(named: "Loading...")],
            "the element is named by the default text when the host's text is empty, not left without a name"
        )
    }

    func test_success_accessibleLayout_listsTheMessageOnlyAtTheAccessibilitySize() {
        guard let sut = makeSUT(showing: .success, layout: .accessible) else { return }

        XCTAssertEqual(sut.signatures, [successText], "pins today's behaviour: the message only")
        XCTAssertTrue(sut.elements.areInReadingOrder, "the elements stand in reading order, top to bottom")
        XCTAssertGreaterThan(
            sut.elements.first?.frame.height ?? 0,
            130,
            "the success is drawn at the accessibility size (107 points in the standard card)"
        )
    }

    func test_failure_accessibleLayout_listsTheTitleTheMessageAndCloseAtTheAccessibilitySize() {
        guard let sut = makeSUT(showing: .failure, layout: .accessible) else { return }

        XCTAssertEqual(
            sut.signatures,
            [failureTitle, failureMessage, closeButton],
            "pins today's behaviour: the title carries no header trait; Close is the only button"
        )
        XCTAssertTrue(sut.elements.areInReadingOrder, "the elements stand in reading order, top to bottom")
        XCTAssertGreaterThan(
            sut.elements.first?.frame.height ?? 0,
            80,
            "the title is drawn at the accessibility size (20 points in the standard card)"
        )
    }

    func test_failureWithRetry_accessibleLayout_stacksCloseAboveRetryAtTheAccessibilitySize() {
        guard let sut = makeSUT(showing: .failureWithRetry, layout: .accessible),
              let close = sut.element(labeled: "Close"),
              let retry = sut.element(labeled: "Retry") else { return }

        XCTAssertEqual(
            sut.signatures,
            [failureTitle, failureMessage, closeButton, retryButton],
            "pins today's behaviour: the title carries no header trait; Close comes before Retry"
        )
        XCTAssertTrue(sut.elements.areInReadingOrder, "the elements stand in reading order, top to bottom")
        XCTAssertLessThan(
            close.frame.maxY,
            retry.frame.minY,
            "at accessibility text sizes Close stands above Retry, not beside it"
        )
    }

    // MARK: - Helpers

    private static let customText = "Please wait while we save your data"

    /// The loading card as one element: named by `text`, which says that its content changes.
    private func loadingCard(named text: String) -> String {
        "label=\"\(text)\" value=nil traits=updatesFrequently"
    }

    private func makeSUT(
        showing shown: HUDShownState,
        layout: HUDAccessibilityLayout = .standard,
        loadingText: String? = nil,
        file: StaticString = #filePath,
        line: UInt = #line
    ) -> HostedHUD? {
        makeHostedHUD(showing: shown, layout: layout, loadingText: loadingText, file: file, line: line)
    }
}
