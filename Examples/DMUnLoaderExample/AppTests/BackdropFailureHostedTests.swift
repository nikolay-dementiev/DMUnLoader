import DMUnLoader
import UIKit
import XCTest

/// A host that gives its settings a handler of the backdrop failure, in the real HUD window of a real
/// scene. The blur of this system works, so the host is told nothing and the HUD is what it always was.
/// That the handler reaches the blur view when the blur fails is held by the package tests, which make
/// the real blur view fail: nothing public makes the real effect fail.
@MainActor
final class BackdropFailureHostedTests: XCTestCase {

    func test_managerWithABackdropHandler_showsTheHUDAsBefore_andIsNotToldWhileTheBlurWorks() throws {
        let (scene, sceneDelegate) = try connectedSceneDelegate()
        defer { sceneDelegate.loadingManager = DMLoadingManagerMain() }
        let spy = FailureSpy()
        let manager = DMLoadingManagerMain(
            state: .none,
            settings: DMLoadingManagerDefaultSettings(
                autoHideDelay: .seconds(600),
                onBackdropFailure: { spy.record($0) }
            )
        )
        sceneDelegate.loadingManager = manager
        let hudWindow = try XCTUnwrap(waitForHUDWindows(in: scene).first, "a HUD window")
        let centre = CGPoint(x: hudWindow.bounds.midX, y: hudWindow.bounds.midY)

        manager.showLoading(provider: DefaultDMLoadingViewProvider())
        let takesTouches = waitUntil(hudWindow.hitTest(centre, with: nil) != nil)
        let deadline = Date().addingTimeInterval(1.5)
        while Date() < deadline {
            RunLoop.current.run(until: Date().addingTimeInterval(0.05))
        }

        XCTAssertTrue(takesTouches, "the HUD is shown in the real window and takes the touch")
        XCTAssertTrue(
            hudWindow.hitTest(centre, with: nil) != nil,
            "the HUD is still shown and takes the touch once the blur had time to be drawn"
        )
        XCTAssertEqual(spy.received, [], "the blur of this system works, so the host is told nothing")
        guard case .loading = manager.loadableState else {
            return XCTFail("the state of the manager is the loading it was given: \(manager.loadableState)")
        }
    }
}

@MainActor
private final class FailureSpy {
    private(set) var received: [DMHUDBackdropFailure] = []

    func record(_ failure: DMHUDBackdropFailure) {
        received.append(failure)
    }
}
