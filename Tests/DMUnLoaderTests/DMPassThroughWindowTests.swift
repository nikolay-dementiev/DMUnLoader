//
//  DMUnLoader
//
//  Created by Mykola Dementiev
//

import UIKit
import XCTest
import DMUnLoader

/// The HUD window takes a touch only while it shows a HUD; otherwise the touch goes to
/// the windows under it.
@MainActor
final class DMPassThroughWindowTests: XCTestCase {

    func test_hitTest_whileNoHUDIsShown_letsTheTouchThrough() {
        let sut = makeSUT()
        sut.interceptsTouches = false

        XCTAssertNil(sut.hitTest(CGPoint(x: 50, y: 50), with: nil), "no view of the HUD window takes the touch")
    }

    func test_hitTest_whileAHUDIsShown_takesTheTouch() {
        let sut = makeSUT()
        sut.interceptsTouches = true

        XCTAssertNotNil(sut.hitTest(CGPoint(x: 50, y: 50), with: nil), "the HUD window takes the touch")
    }

    // MARK: - Accessibility escape

    func test_window_accessibilityEscape_returnsTheHandlersResult() {
        let sut = makeSUT()

        let withoutHandler = sut.accessibilityPerformEscape()
        sut.escapeHandler = { true }
        let handled = sut.accessibilityPerformEscape()
        sut.escapeHandler = { false }
        let declined = sut.accessibilityPerformEscape()

        XCTAssertFalse(withoutHandler, "without a handler the escape does nothing")
        XCTAssertTrue(handled, "the escape reports that the handler hid the HUD")
        XCTAssertFalse(declined, "the escape reports that the handler kept the HUD")
    }

    // MARK: - Helpers

    private func makeSUT(file: StaticString = #filePath, line: UInt = #line) -> DMPassThroughWindow {
        let sut = DMPassThroughWindow(frame: CGRect(x: 0, y: 0, width: 100, height: 100))
        sut.rootViewController = UIViewController(nibName: nil, bundle: nil)
        sut.isHidden = false
        addTeardownBlock { [weak sut] in
            sut?.isHidden = true
        }
        trackForMemoryLeaks(sut, file: file, line: line)
        return sut
    }
}
