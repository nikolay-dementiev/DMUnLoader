//
//  DMUnLoader
//
//  Created by Mykola Dementiev
//

import XCTest
import DMUnLoader

/// When the HUD of a scene is presented and removed. The presenter is a spy, so no scene and
/// no window is needed.
@MainActor
final class HUDOverlayLifecycleTests: XCTestCase {

    func test_managerSet_afterConnect_presentsIt() {
        let (sut, presenter) = makeSUT()
        sut.sceneDidConnect(presenter: presenter)
        let manager = DMLoadingManagerMain()

        sut.loadingManagerDidChange(to: manager)

        XCTAssertEqual(
            presenter.presented.map(ObjectIdentifier.init),
            [ObjectIdentifier(manager)],
            "one presentation of that manager"
        )
    }

    func test_sameManagerSetAgain_afterConnect_keepsTheHUD() {
        let (sut, presenter) = makeSUT()
        sut.sceneDidConnect(presenter: presenter)
        let manager = DMLoadingManagerMain()
        sut.loadingManagerDidChange(to: manager)

        sut.loadingManagerDidChange(to: manager)

        XCTAssertEqual(presenter.presented.count, 1, "the HUD of that manager is already shown: nothing is built again")
    }

    func test_connect_afterTheManagerWasSet_presentsIt() {
        let (sut, presenter) = makeSUT()
        let manager = DMLoadingManagerMain()
        sut.loadingManagerDidChange(to: manager)

        sut.sceneDidConnect(presenter: presenter)

        XCTAssertEqual(
            presenter.presented.map(ObjectIdentifier.init),
            [ObjectIdentifier(manager)],
            "a manager set before the scene connected is shown once it connects"
        )
    }

    func test_managerSetToNil_afterAManagerWasShown_removesTheHUD() {
        let (sut, presenter) = makeSUT()
        sut.sceneDidConnect(presenter: presenter)
        sut.loadingManagerDidChange(to: DMLoadingManagerMain())

        sut.loadingManagerDidChange(to: DMLoadingManagerMain?.none)

        XCTAssertEqual(presenter.dismissCount, 1, "without a manager the HUD is removed")
    }

    func test_otherManagerSet_afterAManagerWasShown_presentsTheNewOne() {
        let (sut, presenter) = makeSUT()
        sut.sceneDidConnect(presenter: presenter)
        let first = DMLoadingManagerMain()
        let second = DMLoadingManagerMain()
        sut.loadingManagerDidChange(to: first)

        sut.loadingManagerDidChange(to: second)

        XCTAssertEqual(
            presenter.presented.map(ObjectIdentifier.init),
            [ObjectIdentifier(first), ObjectIdentifier(second)],
            "a replaced manager has its HUD presented in place of the first"
        )
    }

    func test_sceneDidDisconnect_afterAManagerWasShown_removesTheHUD() {
        let (sut, presenter) = makeSUT()
        sut.sceneDidConnect(presenter: presenter)
        sut.loadingManagerDidChange(to: DMLoadingManagerMain())

        sut.sceneDidDisconnect()

        XCTAssertEqual(presenter.dismissCount, 1, "the HUD leaves with its scene")
    }

    func test_managerSet_afterTheSceneDisconnected_presentsNothing() {
        let (sut, presenter) = makeSUT()
        sut.sceneDidConnect(presenter: presenter)
        sut.sceneDidDisconnect()

        sut.loadingManagerDidChange(to: DMLoadingManagerMain())

        XCTAssertTrue(presenter.presented.isEmpty, "a disconnected scene shows no HUD")
    }

    func test_reconnect_afterADisconnect_presentsTheManagerOnTheNewScene() {
        let (sut, firstScene) = makeSUT()
        let secondScene = HUDOverlayPresenterSpy()
        let manager = DMLoadingManagerMain()
        sut.sceneDidConnect(presenter: firstScene)
        sut.loadingManagerDidChange(to: manager)
        sut.sceneDidDisconnect()

        sut.sceneDidConnect(presenter: secondScene)

        XCTAssertEqual(
            secondScene.presented.map(ObjectIdentifier.init),
            [ObjectIdentifier(manager)],
            "the manager comes back with the scene"
        )
    }

    func test_twoScenes_disconnectOfOne_keepsTheHUDOfTheOther() {
        let (first, firstPresenter) = makeSUT()
        let (second, secondPresenter) = makeSUT()
        first.sceneDidConnect(presenter: firstPresenter)
        second.sceneDidConnect(presenter: secondPresenter)
        first.loadingManagerDidChange(to: DMLoadingManagerMain())
        second.loadingManagerDidChange(to: DMLoadingManagerMain())

        first.sceneDidDisconnect()

        XCTAssertEqual(secondPresenter.dismissCount, 0, "each scene has a lifecycle and a HUD of its own")
    }

    // MARK: - Helpers

    private func makeSUT(
        file: StaticString = #filePath,
        line: UInt = #line
    ) -> (sut: HUDOverlayLifecycle, presenter: HUDOverlayPresenterSpy) {
        let sut = HUDOverlayLifecycle()
        let presenter = HUDOverlayPresenterSpy()
        trackForMemoryLeaks(sut, file: file, line: line)
        return (sut, presenter)
    }
}
