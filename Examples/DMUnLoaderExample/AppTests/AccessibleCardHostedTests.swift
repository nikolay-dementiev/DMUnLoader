import DMUnLoader
import UIKit
import XCTest

/// Where the accessible card lies in a real HUD window when its view is taller than the screen. The card
/// scrolls then, and what scrolls has to stay inside the safe area of the window, so that the status bar
/// and the home indicator do not cover the first and the last line of a message.
@MainActor
final class AccessibleCardHostedTests: XCTestCase {

    func test_accessibleCard_tallerThanTheScreen_scrollsInsideTheSafeAreaOfItsWindow() throws {
        let (scene, sceneDelegate) = try connectedSceneDelegate()
        defer { sceneDelegate.loadingManager = DMLoadingManagerMain() }
        sceneDelegate.loadingManager = DMLoadingManagerMain(
            state: .failure(
                error: DMAppError.custom(String(repeating: "The server did not answer the request in time. ", count: 14)),
                provider: DefaultDMLoadingViewProvider(appearance: .accessible).eraseToAnyViewProvider(),
                onRetry: DMButtonAction {}
            ),
            settings: DMLoadingManagerDefaultSettings(autoHideDelay: .seconds(600))
        )
        let hudWindow = try XCTUnwrap(waitForHUDWindows(in: scene).first, "a HUD window")
        hudWindow.traitOverrides.preferredContentSizeCategory = .accessibilityExtraExtraExtraLarge

        let scrollView = try XCTUnwrap(
            waitForScrollView(in: hudWindow),
            "the card scrolls: its message is taller than the screen"
        )

        let scrolls = waitUntil(scrollView.contentSize.height > scrollView.bounds.height)
        let frame = scrollView.convert(scrollView.bounds, to: hudWindow)
        let safeArea = hudWindow.bounds.inset(by: hudWindow.safeAreaInsets)
        XCTAssertTrue(
            scrolls,
            "precondition: the message is taller than the card, whose content is \(scrollView.contentSize) in \(frame)"
        )
        XCTAssertGreaterThanOrEqual(
            frame.minY,
            safeArea.minY - 0.5,
            "the top of the scrolling card (\(frame)) lies inside the safe area (\(safeArea)) of the window"
        )
        XCTAssertLessThanOrEqual(
            frame.maxY,
            safeArea.maxY + 0.5,
            "the bottom of the scrolling card (\(frame)) lies inside the safe area (\(safeArea)) of the window"
        )
    }

    // MARK: - Helpers

    private func waitForScrollView(in window: UIWindow) -> UIScrollView? {
        _ = waitUntil(scrollView(in: window) != nil)
        return scrollView(in: window)
    }

    private func scrollView(in view: UIView) -> UIScrollView? {
        if let scrollView = view as? UIScrollView {
            return scrollView
        }
        for subview in view.subviews {
            if let found = scrollView(in: subview) {
                return found
            }
        }
        return nil
    }
}
