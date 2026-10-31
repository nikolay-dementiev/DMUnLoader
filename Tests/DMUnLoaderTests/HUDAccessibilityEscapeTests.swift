//
//  DMUnLoader
//
//  Created by Mykola Dementiev
//

import UIKit
import XCTest

/// The escape gesture of VoiceOver, the two-finger scrub, as a test can model it: `accessibilityPerformEscape()`
/// on the focused element and then on each object above it, the containers of an element and the
/// superviews of a view, until one returns `true`.
///
/// The model is the routing that VoiceOver is understood to take for the gesture, from the focused element
/// up through its ancestors. VoiceOver does not run on the Simulator, so its own routing is not observed;
/// the tests hold what the walk finds: only the HUD window handles the escape, nothing in front of it
/// claims it, and the HUD goes when it is handled. A loading HUD cannot be escaped, so nobody handles it
/// and the HUD stays.
@MainActor
final class HUDAccessibilityEscapeTests: XCTestCase {

    // MARK: - A HUD that can be escaped

    func test_escape_successStandardLayout_fromItsMessage_isHandledByTheHUDWindow() {
        assertEscapeHidesTheHUD(showing: .success, layout: .standard, from: "Saved")
    }

    func test_escape_successAccessibleLayout_fromItsMessage_isHandledByTheHUDWindow() {
        assertEscapeHidesTheHUD(showing: .success, layout: .accessible, from: "Saved")
    }

    func test_escape_failureStandardLayout_fromClose_isHandledByTheHUDWindow() {
        assertEscapeHidesTheHUD(showing: .failure, layout: .standard, from: "Close")
    }

    func test_escape_failureAccessibleLayout_fromClose_isHandledByTheHUDWindow() {
        assertEscapeHidesTheHUD(showing: .failure, layout: .accessible, from: "Close")
    }

    func test_escape_failureWithRetryStandardLayout_fromRetry_isHandledByTheHUDWindow() {
        assertEscapeHidesTheHUD(showing: .failureWithRetry, layout: .standard, from: "Retry")
    }

    func test_escape_failureWithRetryAccessibleLayout_fromClose_isHandledByTheHUDWindow() {
        assertEscapeHidesTheHUD(showing: .failureWithRetry, layout: .accessible, from: "Close")
    }

    func test_escape_failureWithRetryStandardLayout_hidesTheHUDWithoutRetrying() {
        guard let sut = makeSUT(showing: .failureWithRetry, layout: .standard) else { return }
        guard let close = sut.element(labeled: "Close") else {
            return XCTFail("the HUD has an element labelled Close")
        }

        let chain = HUDAccessibilityTree.escapeChain(from: close.object)

        XCTAssertTrue(chain.last?.handled == true, "the escape was handled: \(describe(chain))")
        XCTAssertEqual(sut.manager.loadableState, .none, "the escape hides the failure, as a tap outside the card does")
        XCTAssertEqual(sut.retries.count, 0, "the escape does not retry")
    }

    // MARK: - A HUD that cannot be escaped

    func test_escape_loadingStandardLayout_isHandledByNobodyAndTheHUDStays() {
        assertEscapeIsRefused(layout: .standard)
    }

    func test_escape_loadingAccessibleLayout_isHandledByNobodyAndTheHUDStays() {
        assertEscapeIsRefused(layout: .accessible)
    }

    // MARK: - Helpers

    private func makeSUT(
        showing shown: HUDShownState,
        layout: HUDAccessibilityLayout,
        file: StaticString = #filePath,
        line: UInt = #line
    ) -> HostedHUD? {
        makeHostedHUD(showing: shown, layout: layout, file: file, line: line)
    }

    private func assertEscapeHidesTheHUD(
        showing shown: HUDShownState,
        layout: HUDAccessibilityLayout,
        from label: String,
        file: StaticString = #filePath,
        line: UInt = #line
    ) {
        guard let sut = makeSUT(showing: shown, layout: layout, file: file, line: line) else { return }
        guard let start = sut.element(labeled: label), let window = sut.window else {
            return XCTFail("the HUD has a window and an element labelled \(label)", file: file, line: line)
        }
        let hostingView = window.rootViewController?.view

        // The walk stops at the first object that handles the escape, so this one is the last of the
        // chain, and every object before it has declined.
        let chain = HUDAccessibilityTree.escapeChain(from: start.object)

        XCTAssertTrue(
            chain.last?.object === window && chain.last?.handled == true,
            "the HUD window is the first object to handle the escape, and nothing before it did: \(describe(chain))",
            file: file,
            line: line
        )
        XCTAssertTrue(
            chain.contains { $0.object === hostingView },
            "the walk passes through the hosting view of the HUD: \(describe(chain))",
            file: file,
            line: line
        )
        XCTAssertEqual(sut.manager.loadableState, .none, "the handled escape hides the HUD", file: file, line: line)
        XCTAssertTrue(
            turnRunLoop(until: sut.window != nil && !sut.takesTouches),
            "a hidden HUD lets the touches through once the window has heard of the new state",
            file: file,
            line: line
        )
    }

    private func assertEscapeIsRefused(
        layout: HUDAccessibilityLayout,
        file: StaticString = #filePath,
        line: UInt = #line
    ) {
        guard let sut = makeSUT(showing: .loading, layout: layout, file: file, line: line) else { return }
        guard let start = sut.elements.first, let window = sut.window else {
            return XCTFail("the loading HUD has a window and an element", file: file, line: line)
        }
        let stateBefore = sut.manager.loadableState

        let chain = HUDAccessibilityTree.escapeChain(from: start.object)

        XCTAssertTrue(
            chain.allSatisfy { !$0.handled },
            "no object handles the escape of a loading HUD: \(describe(chain))",
            file: file,
            line: line
        )
        XCTAssertTrue(
            chain.last?.object === window,
            "the walk reaches the HUD window, which declines: \(describe(chain))",
            file: file,
            line: line
        )
        XCTAssertEqual(sut.manager.loadableState, stateBefore, "the loading HUD stays", file: file, line: line)
        XCTAssertTrue(sut.takesTouches, "the loading HUD still takes the touches", file: file, line: line)
    }

    private func describe(_ chain: [HUDAccessibilityTree.EscapeStep]) -> String {
        chain.map { "\(type(of: $0.object))=\($0.handled)" }.joined(separator: " -> ")
    }
}
