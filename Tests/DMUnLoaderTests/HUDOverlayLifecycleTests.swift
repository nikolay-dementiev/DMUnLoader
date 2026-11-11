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

    func test_connect_afterTheCallerLetGoOfTheManager_stillPresentsIt() {
        let (sut, presenter) = makeSUT()
        // Once the call returns, nothing but the lifecycle holds this manager.
        sut.loadingManagerDidChange(to: DMLoadingManagerMain())

        sut.sceneDidConnect(presenter: presenter)

        XCTAssertEqual(
            presenter.presented.count,
            1,
            "a manager that only the lifecycle holds is still shown once the scene connects"
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

    func test_sameManagerSetAgain_afterNil_presentsItAgain() {
        let (sut, presenter) = makeSUT()
        sut.sceneDidConnect(presenter: presenter)
        let manager = DMLoadingManagerMain()
        sut.loadingManagerDidChange(to: manager)
        sut.loadingManagerDidChange(to: DMLoadingManagerMain?.none)

        sut.loadingManagerDidChange(to: manager)

        XCTAssertEqual(
            presenter.presented.map(ObjectIdentifier.init),
            [ObjectIdentifier(manager), ObjectIdentifier(manager)],
            "a manager set again after nil gets its HUD back"
        )
    }

    func test_connect_afterTheManagerWasSetAndThenRemoved_presentsNothing() {
        let (sut, presenter) = makeSUT()
        sut.loadingManagerDidChange(to: DMLoadingManagerMain())
        sut.loadingManagerDidChange(to: DMLoadingManagerMain?.none)

        sut.sceneDidConnect(presenter: presenter)

        XCTAssertTrue(
            presenter.presented.isEmpty,
            "a manager that was taken away before the scene connected is not shown when it does"
        )
    }

    func test_otherManagerSet_afterAManagerWasShown_dismissesNothing() {
        let (sut, presenter) = makeSUT()
        sut.sceneDidConnect(presenter: presenter)
        sut.loadingManagerDidChange(to: DMLoadingManagerMain())

        sut.loadingManagerDidChange(to: DMLoadingManagerMain())

        XCTAssertEqual(presenter.dismissCount, 0, "the new manager takes over the HUD: nothing is removed")
    }

    func test_secondConnect_withoutADisconnect_removesTheHUDOfTheFirstPresenter() {
        let (sut, firstPresenter) = makeSUT()
        let secondPresenter = HUDOverlayPresenterSpy()
        sut.sceneDidConnect(presenter: firstPresenter)
        sut.loadingManagerDidChange(to: DMLoadingManagerMain())

        sut.sceneDidConnect(presenter: secondPresenter)

        XCTAssertEqual(firstPresenter.dismissCount, 1, "a HUD is left behind by no presenter")
    }

    func test_secondConnect_withoutADisconnect_presentsTheManagerOnTheSecondPresenter() {
        let (sut, firstPresenter) = makeSUT()
        let secondPresenter = HUDOverlayPresenterSpy()
        let manager = DMLoadingManagerMain()
        sut.sceneDidConnect(presenter: firstPresenter)
        sut.loadingManagerDidChange(to: manager)

        sut.sceneDidConnect(presenter: secondPresenter)

        XCTAssertEqual(
            secondPresenter.presented.map(ObjectIdentifier.init),
            [ObjectIdentifier(manager)],
            "a connect starts over: the manager that the first presenter showed is shown by the second"
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

    // MARK: - Presentations built by hand
    //
    // The lifecycle sees an identity and an action, never the owner behind them. These tests give it
    // exactly that, so they hold for any maker of presentations, not only for a loading manager.

    func test_presentationOfTheSameID_setAgain_isNotShownAgain() {
        let (sut, presenter) = makeSUT()
        let recorder = ShowRecorder()
        let owner = Owner()
        sut.sceneDidConnect(presenter: presenter)
        sut.presentationDidChange(to: recorder.presentation(of: owner, named: "first"))

        sut.presentationDidChange(to: recorder.presentation(of: owner, named: "second"))

        XCTAssertEqual(
            recorder.shown.map(\.name),
            ["first"],
            "the identity decides: the same one again keeps the HUD, whatever action comes with it"
        )
    }

    func test_presentationOfAnotherID_setAfterOne_isShown() {
        let (sut, presenter) = makeSUT()
        let recorder = ShowRecorder()
        let firstOwner = Owner()
        let secondOwner = Owner()
        sut.sceneDidConnect(presenter: presenter)
        sut.presentationDidChange(to: recorder.presentation(of: firstOwner, named: "first"))

        sut.presentationDidChange(to: recorder.presentation(of: secondOwner, named: "second"))

        XCTAssertEqual(recorder.shown.map(\.name), ["first", "second"], "another identity takes over the HUD")
    }

    func test_reconnect_afterTheSameIDWasSetTwice_showsTheLatestPresentationThroughTheNewPresenter() {
        let (sut, firstPresenter) = makeSUT()
        let secondPresenter = HUDOverlayPresenterSpy()
        let recorder = ShowRecorder()
        let owner = Owner()
        sut.sceneDidConnect(presenter: firstPresenter)
        sut.presentationDidChange(to: recorder.presentation(of: owner, named: "first"))
        sut.presentationDidChange(to: recorder.presentation(of: owner, named: "second"))
        sut.sceneDidDisconnect()

        sut.sceneDidConnect(presenter: secondPresenter)

        XCTAssertEqual(
            recorder.shown.map(\.name),
            ["first", "second"],
            "the same identity is not shown again while connected; a reconnect shows the latest presentation of it"
        )
        XCTAssertEqual(
            recorder.shown.map(\.presenter),
            [ObjectIdentifier(firstPresenter), ObjectIdentifier(secondPresenter)],
            "each connect shows the HUD through its own presenter, and the first is not asked again"
        )
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

// MARK: - Doubles for the presentations built by hand

private final class Owner {}

/// Makes presentations that record, when shown, their name and the presenter they were given.
@MainActor
private final class ShowRecorder {
    struct Show {
        let name: String
        let presenter: ObjectIdentifier
    }

    private(set) var shown: [Show] = []

    /// Holds `owner` as the adapter of a loading manager does, so its identity stays its own while
    /// the presentation lives.
    func presentation(of owner: Owner, named name: String) -> HUDPresentation {
        HUDPresentation(id: ObjectIdentifier(owner)) { [self, owner] presenter in
            _ = owner
            shown.append(Show(name: name, presenter: ObjectIdentifier(presenter)))
        }
    }
}
