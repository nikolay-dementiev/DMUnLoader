//
//  DMUnLoader
//
//  Created by Mykola Dementiev
//

import UIKit
import XCTest

/// What happens when assistive technology activates an element of the HUD, the way VoiceOver does with a
/// double tap: `accessibilityActivate()` on the element of Retry and of Close, and the point it taps.
///
/// Close hides the HUD and Retry runs the retry action and leaves the state, as a tap on the button does.
/// Each element names an activation point; VoiceOver taps there when `accessibilityActivate()` returns
/// `false`, so the point must lie in the element and the HUD must take the touch there.
@MainActor
final class HUDAccessibilityActivationTests: XCTestCase {

    // MARK: - Retry

    func test_retry_standardLayout_activated_runsTheRetryActionOnceAndKeepsTheState() {
        assertRetryRunsOnce(layout: .standard)
    }

    func test_retry_accessibleLayout_activated_runsTheRetryActionOnceAndKeepsTheState() {
        assertRetryRunsOnce(layout: .accessible)
    }

    // MARK: - Close

    func test_close_standardLayout_activatedOnAFailureWithRetry_hidesTheHUDWithoutRetrying() {
        assertCloseHides(showing: .failureWithRetry, layout: .standard)
    }

    func test_close_accessibleLayout_activatedOnAFailureWithRetry_hidesTheHUDWithoutRetrying() {
        assertCloseHides(showing: .failureWithRetry, layout: .accessible)
    }

    func test_close_standardLayout_activatedOnAFailureWithoutRetry_hidesTheHUD() {
        assertCloseHides(showing: .failure, layout: .standard)
    }

    func test_close_accessibleLayout_activatedOnAFailureWithoutRetry_hidesTheHUD() {
        assertCloseHides(showing: .failure, layout: .accessible)
    }

    func test_failureWithoutRetry_standardLayout_hasCloseAsItsOnlyButton() {
        guard let sut = makeSUT(showing: .failure) else { return }

        XCTAssertEqual(
            sut.elements.filter { $0.traits.contains(.button) }.map { $0.label ?? "(no label)" },
            ["Close"],
            "a failure without a retry action offers Close and no Retry, and no button without a label"
        )
    }

    // MARK: - The activation point

    func test_activationPoints_loadingStandardLayout_lieInTheirElementsAndInTheHUD() {
        assertActivationPointsLieInTheHUD(showing: .loading, layout: .standard, expectedElements: 2)
    }

    func test_activationPoints_successStandardLayout_lieInTheirElementsAndInTheHUD() {
        assertActivationPointsLieInTheHUD(showing: .success, layout: .standard, expectedElements: 1)
    }

    func test_activationPoints_failureWithRetryStandardLayout_lieInTheirElementsAndInTheHUD() {
        assertActivationPointsLieInTheHUD(showing: .failureWithRetry, layout: .standard, expectedElements: 4)
    }

    func test_activationPoints_loadingAccessibleLayout_lieInTheirElementsAndInTheHUD() {
        assertActivationPointsLieInTheHUD(showing: .loading, layout: .accessible, expectedElements: 2)
    }

    func test_activationPoints_successAccessibleLayout_lieInTheirElementsAndInTheHUD() {
        assertActivationPointsLieInTheHUD(showing: .success, layout: .accessible, expectedElements: 1)
    }

    func test_activationPoints_failureWithRetryAccessibleLayout_lieInTheirElementsAndInTheHUD() {
        assertActivationPointsLieInTheHUD(showing: .failureWithRetry, layout: .accessible, expectedElements: 4)
    }

    // MARK: - Helpers

    private func makeSUT(
        showing shown: HUDShownState,
        layout: HUDAccessibilityLayout = .standard,
        file: StaticString = #filePath,
        line: UInt = #line
    ) -> HostedHUD? {
        makeHostedHUD(showing: shown, layout: layout, file: file, line: line)
    }

    private func assertRetryRunsOnce(layout: HUDAccessibilityLayout, file: StaticString = #filePath, line: UInt = #line) {
        guard let sut = makeSUT(showing: .failureWithRetry, layout: layout, file: file, line: line) else { return }
        guard let retry = sut.element(labeled: "Retry") else {
            return XCTFail("the HUD has an element labelled Retry", file: file, line: line)
        }
        let stateBefore = sut.manager.loadableState

        let activated = retry.object.accessibilityActivate()

        XCTAssertTrue(activated, "the element of Retry takes the activation itself", file: file, line: line)
        XCTAssertEqual(sut.retries.count, 1, "activating Retry runs the retry action once", file: file, line: line)
        XCTAssertEqual(
            sut.manager.loadableState,
            stateBefore,
            "the state stays what it was: what follows a retry is for the host to decide",
            file: file,
            line: line
        )
        XCTAssertTrue(sut.takesTouches, "the HUD is still shown after a retry", file: file, line: line)
    }

    private func assertCloseHides(
        showing shown: HUDShownState,
        layout: HUDAccessibilityLayout,
        file: StaticString = #filePath,
        line: UInt = #line
    ) {
        guard let sut = makeSUT(showing: shown, layout: layout, file: file, line: line) else { return }
        guard let close = sut.element(labeled: "Close") else {
            return XCTFail("the HUD has an element labelled Close", file: file, line: line)
        }

        let activated = close.object.accessibilityActivate()
        let hidden = turnRunLoop(until: sut.manager.loadableState == .none && sut.window != nil && !sut.takesTouches)

        XCTAssertTrue(activated, "the element of Close takes the activation itself", file: file, line: line)
        XCTAssertTrue(hidden, "activating Close hides the HUD and lets the touches through", file: file, line: line)
        XCTAssertEqual(sut.retries.count, 0, "activating Close does not retry", file: file, line: line)
    }

    private func assertActivationPointsLieInTheHUD(
        showing shown: HUDShownState,
        layout: HUDAccessibilityLayout,
        expectedElements: Int,
        file: StaticString = #filePath,
        line: UInt = #line
    ) {
        guard let sut = makeSUT(showing: shown, layout: layout, file: file, line: line),
              let window = sut.window else { return }
        XCTAssertEqual(
            sut.elements.count,
            expectedElements,
            "the whole tree is there to be checked: \(sut.signatures)",
            file: file,
            line: line
        )
        for element in sut.elements {
            let name = element.label ?? "the element without a label"
            let point = window.screen.coordinateSpace.convert(element.activationPoint, to: window)

            XCTAssertFalse(element.frame.isEmpty, "\(name) has a frame", file: file, line: line)
            XCTAssertTrue(
                element.frame.insetBy(dx: -1, dy: -1).contains(element.activationPoint),
                "the activation point of \(name) lies in its own frame",
                file: file,
                line: line
            )
            XCTAssertTrue(
                window.bounds.contains(point),
                "the activation point of \(name) lies in the HUD window",
                file: file,
                line: line
            )
            XCTAssertNotNil(
                window.hitTest(point, with: nil),
                "the HUD window takes the touch at the activation point of \(name)",
                file: file,
                line: line
            )
        }
    }
}
