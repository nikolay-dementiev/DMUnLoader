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
