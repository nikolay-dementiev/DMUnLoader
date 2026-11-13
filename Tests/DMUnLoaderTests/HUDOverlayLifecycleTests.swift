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
            presenter.presentedIDs,
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

        XCTAssertEqual(presenter.presentedIDs.count, 1, "the HUD of that manager is already shown: nothing is presented again")
    }

    func test_connect_afterTheManagerWasSet_presentsIt() {
        let (sut, presenter) = makeSUT()
        let manager = DMLoadingManagerMain()
        sut.loadingManagerDidChange(to: manager)

        sut.sceneDidConnect(presenter: presenter)

        XCTAssertEqual(
            presenter.presentedIDs,
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
            presenter.presentedIDs.count,
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
            presenter.presentedIDs,
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
            presenter.presentedIDs,
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
            presenter.presentedIDs.isEmpty,
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

    func test_otherManagerSet_afterAManagerWasShown_releasesTheFirstAndPresentsTheSecond() {
        let sut = makeLifecycle()
        let presenter = IdentityOnlyPresenter()
        trackForMemoryLeaks(presenter)
        var first: DMLoadingManagerMain? = DMLoadingManagerMain()
        let firstIsReleased = { [weak held = first] in held == nil }
        let second = DMLoadingManagerMain()
        sut.sceneDidConnect(presenter: presenter)
        sut.loadingManagerDidChange(to: first)
        let presentedFirst = presenter.presentedIDs
        // Once this reference is gone, nothing but the lifecycle holds the first manager: the presenter keeps none.
        first = nil
        XCTAssertFalse(firstIsReleased(), "the lifecycle holds the manager whose HUD is shown")

        sut.loadingManagerDidChange(to: second)

        XCTAssertTrue(firstIsReleased(), "the lifecycle let go of the manager that the other one replaced")
        XCTAssertEqual(
            presenter.presentedIDs,
            presentedFirst + [ObjectIdentifier(second)],
            "the second manager is the one presented in place of the first"
        )
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
            secondPresenter.presentedIDs,
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

        XCTAssertTrue(presenter.presentedIDs.isEmpty, "a disconnected scene shows no HUD")
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
            secondScene.presentedIDs,
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
    // The lifecycle sees an identity and a content, never the owner behind them. These tests give it
    // exactly that, with a name for a content, so they hold for any maker of presentations, not only
    // for a loading manager.

    func test_presentationOfTheSameID_setAgain_isNotShownAgain() {
        let (sut, recorder) = makeNamedSUT()
        let presenter = recorder.makePresenter()
        let owner = Owner()
        sut.sceneDidConnect(presenter: presenter)
        sut.presentationDidChange(to: recorder.presentation(of: owner, named: "first"))

        sut.presentationDidChange(to: recorder.presentation(of: owner, named: "second"))

        XCTAssertEqual(
            recorder.shown.map(\.name),
            ["first"],
            "the identity decides: the same one again keeps the HUD, whatever content comes with it"
        )
    }

    func test_presentationOfAnotherID_setAfterOne_isShown() {
        let (sut, recorder) = makeNamedSUT()
        let presenter = recorder.makePresenter()
        let firstOwner = Owner()
        let secondOwner = Owner()
        sut.sceneDidConnect(presenter: presenter)
        sut.presentationDidChange(to: recorder.presentation(of: firstOwner, named: "first"))

        sut.presentationDidChange(to: recorder.presentation(of: secondOwner, named: "second"))

        XCTAssertEqual(recorder.shown.map(\.name), ["first", "second"], "another identity takes over the HUD")
    }

    func test_reconnect_afterTheSameIDWasSetTwice_showsTheLatestPresentationThroughTheNewPresenter() {
        let (sut, recorder) = makeNamedSUT()
        let firstPresenter = recorder.makePresenter()
        let secondPresenter = recorder.makePresenter()
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
    ) -> (sut: HUDOverlayLifecycle<HUDComposition>, presenter: HUDOverlayPresenterSpy) {
        (makeLifecycle(file: file, line: line), HUDOverlayPresenterSpy())
    }

    /// A lifecycle with no presenter, for a test that brings a presenter of its own.
    private func makeLifecycle(
        file: StaticString = #filePath,
        line: UInt = #line
    ) -> HUDOverlayLifecycle<HUDComposition> {
        let sut = HUDOverlayLifecycle<HUDComposition>()
        trackForMemoryLeaks(sut, file: file, line: line)
        return sut
    }

    /// A lifecycle over the named contents of the hand-built presentations, with the recorder whose
    /// presenters it is connected to.
    private func makeNamedSUT(
        file: StaticString = #filePath,
        line: UInt = #line
    ) -> (sut: HUDOverlayLifecycle<NamedContent>, recorder: ShowRecorder) {
        let sut = HUDOverlayLifecycle<NamedContent>()
        trackForMemoryLeaks(sut, file: file, line: line)
        return (sut, ShowRecorder())
    }
}

// MARK: - Doubles

/// Records the identity of every presentation it is asked to show and keeps nothing else, unlike
/// `HUDOverlayPresenterSpy`, which keeps the presentations and so the managers behind them. What stays
/// alive after the lifecycle lets go of a manager is then the lifecycle's own doing.
@MainActor
private final class IdentityOnlyPresenter: HUDOverlayPresenting {
    typealias Content = HUDComposition

    private(set) var presentedIDs: [ObjectIdentifier] = []

    func present(_ presentation: HUDPresentation<HUDComposition>) {
        presentedIDs.append(presentation.id)
    }

    func dismiss() {}
}

// MARK: - Doubles for the presentations built by hand

private final class Owner {}

/// The content of a presentation built by hand: a name, and the owner it holds as the content made for
/// a loading manager holds the manager, so the identity stays its own while the presentation lives.
private struct NamedContent {
    let name: String
    let owner: Owner
}

/// Records, for every presentation that its presenters are asked to show, its name and the presenter.
@MainActor
private final class ShowRecorder {
    struct Show {
        let name: String
        let presenter: ObjectIdentifier
    }

    private(set) var shown: [Show] = []

    func makePresenter() -> NamedContentPresenter {
        NamedContentPresenter(recorder: self)
    }

    func presentation(of owner: Owner, named name: String) -> HUDPresentation<NamedContent> {
        HUDPresentation(id: ObjectIdentifier(owner), content: NamedContent(name: name, owner: owner))
    }

    fileprivate func record(_ presentation: HUDPresentation<NamedContent>, shownBy presenter: NamedContentPresenter) {
        shown.append(Show(name: presentation.content.name, presenter: ObjectIdentifier(presenter)))
    }
}

@MainActor
private final class NamedContentPresenter: HUDOverlayPresenting {
    typealias Content = NamedContent

    private let recorder: ShowRecorder

    init(recorder: ShowRecorder) {
        self.recorder = recorder
    }

    func present(_ presentation: HUDPresentation<NamedContent>) {
        recorder.record(presentation, shownBy: self)
    }

    func dismiss() {}
}
