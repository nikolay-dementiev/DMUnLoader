//
//  DMUnLoader
//
//  Created by Mykola Dementiev
//

import XCTest
import DMUnLoader

/// Where the HUD of a root view with an injected loading manager is shown, as the view's
/// scene reader reports the view's moves. The scenes are spies, so no window is needed.
@MainActor
final class RootViewHUDAttachmentTests: XCTestCase {

    func test_injectedManager_beforeTheViewIsInAScene_isShownOnceItIs() {
        let sut = makeSUT()
        let manager = DMLoadingManagerMain()
        let scene = makeScene()
        sut.loadingManagerDidChange(to: manager)

        sut.viewDidMove(to: scene)

        XCTAssertEqual(
            scene.presented,
            [ObjectIdentifier(manager)],
            "a view that is in no scene yet waits with its manager, which is shown once the view is in one"
        )
    }

    func test_viewInASceneWindow_presentsTheInjectedManagerOnThatScene() {
        let sut = makeSUT()
        let manager = DMLoadingManagerMain()
        let scene = makeScene()
        sut.viewDidMove(to: scene)

        sut.loadingManagerDidChange(to: manager)

        XCTAssertEqual(
            scene.presented,
            [ObjectIdentifier(manager)],
            "the HUD of the injected manager is shown over the scene of the view"
        )
    }

    func test_viewLeavesItsWindow_removesTheHUD_andComingBackShowsItAgain() {
        let sut = makeSUT()
        let manager = DMLoadingManagerMain()
        let scene = makeScene()
        sut.loadingManagerDidChange(to: manager)
        sut.viewDidMove(to: scene)

        sut.viewDidMove(to: nil)
        let dismissedOnLeaving = scene.dismissCount
        sut.viewDidMove(to: scene)

        XCTAssertEqual(dismissedOnLeaving, 1, "leaving the window removes the HUD from the scene")
        XCTAssertEqual(
            scene.presented,
            [ObjectIdentifier(manager), ObjectIdentifier(manager)],
            "back in a window of the scene, the kept manager is shown again"
        )
    }

    func test_otherManagerInjected_takesOverTheHUD() {
        let sut = makeSUT()
        let first = DMLoadingManagerMain()
        let second = DMLoadingManagerMain()
        let scene = makeScene()
        sut.loadingManagerDidChange(to: first)
        sut.viewDidMove(to: scene)

        sut.loadingManagerDidChange(to: second)

        XCTAssertEqual(
            scene.presented,
            [ObjectIdentifier(first), ObjectIdentifier(second)],
            "the manager of a later update takes over the HUD"
        )
    }

    func test_twoRootViews_inTwoScenes_eachPresentsOnItsOwnScene() {
        let firstView = makeSUT()
        let secondView = makeSUT()
        let firstScene = makeScene()
        let secondScene = makeScene()
        let firstManager = DMLoadingManagerMain()
        let secondManager = DMLoadingManagerMain()
        firstView.loadingManagerDidChange(to: firstManager)
        secondView.loadingManagerDidChange(to: secondManager)

        firstView.viewDidMove(to: firstScene)
        secondView.viewDidMove(to: secondScene)

        XCTAssertEqual(
            firstScene.presented,
            [ObjectIdentifier(firstManager)],
            "the first view's HUD is over the first view's scene only"
        )
        XCTAssertEqual(
            secondScene.presented,
            [ObjectIdentifier(secondManager)],
            "the second view's HUD is over the second view's scene only"
        )
    }

    func test_sameSceneReportedAgain_keepsTheHUD() {
        let sut = makeSUT()
        let scene = makeScene()
        sut.loadingManagerDidChange(to: DMLoadingManagerMain())
        sut.viewDidMove(to: scene)

        sut.viewDidMove(to: scene)

        XCTAssertEqual(scene.presenters.count, 1, "a second report of the same scene builds no second presenter")
        XCTAssertEqual(scene.dismissCount, 0, "a second report of the same scene keeps the HUD shown")
    }

    func test_viewMovesToAnotherScene_movesTheHUDThere() {
        let sut = makeSUT()
        let manager = DMLoadingManagerMain()
        let first = makeScene()
        let second = makeScene()
        sut.loadingManagerDidChange(to: manager)
        sut.viewDidMove(to: first)

        sut.viewDidMove(to: second)

        XCTAssertEqual(first.dismissCount, 1, "the scene the view left loses the HUD")
        XCTAssertEqual(second.presented, [ObjectIdentifier(manager)], "the scene the view moved to shows the HUD")
    }

    func test_sceneDisconnects_removesTheHUD_andTheViewInASceneAgainShowsIt() {
        let sut = makeSUT()
        let manager = DMLoadingManagerMain()
        let scene = makeScene()
        sut.loadingManagerDidChange(to: manager)
        sut.viewDidMove(to: scene)

        scene.disconnect()
        let dismissedOnDisconnect = scene.dismissCount
        sut.viewDidMove(to: scene)

        XCTAssertEqual(dismissedOnDisconnect, 1, "a scene that disconnects loses the HUD")
        XCTAssertEqual(
            scene.presented,
            [ObjectIdentifier(manager), ObjectIdentifier(manager)],
            "the kept manager is shown when the view is reported in a scene again"
        )
    }

    // MARK: - Helpers

    private func makeSUT(file: StaticString = #filePath, line: UInt = #line) -> RootViewHUDAttachment {
        let sut = RootViewHUDAttachment()
        trackForMemoryLeaks(sut, file: file, line: line)
        return sut
    }

    private func makeScene(file: StaticString = #filePath, line: UInt = #line) -> HUDSceneSpy {
        let scene = HUDSceneSpy()
        trackForMemoryLeaks(scene, file: file, line: line)
        return scene
    }
}
