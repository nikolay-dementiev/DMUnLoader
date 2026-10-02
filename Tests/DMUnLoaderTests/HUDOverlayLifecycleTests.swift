//
//  DMUnLoader
//
//  Created by Mykola Dementiev
//

import XCTest
import DMUnLoader

/// When the HUD of a scene is presented, as the lifecycle decides it today. The presenter is
/// a spy, so no scene and no window is needed.
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

    func test_sameManagerSetAgain_afterConnect_presentsItAgain() {
        let (sut, presenter) = makeSUT()
        sut.sceneDidConnect(presenter: presenter)
        let manager = DMLoadingManagerMain()
        sut.loadingManagerDidChange(to: manager)

        sut.loadingManagerDidChange(to: manager)

        XCTAssertEqual(presenter.presented.count, 2, "today every assignment builds the HUD again")
    }

    func test_connect_afterTheManagerWasSet_presentsNothing() {
        let (sut, presenter) = makeSUT()
        sut.loadingManagerDidChange(to: DMLoadingManagerMain())

        sut.sceneDidConnect(presenter: presenter)

        XCTAssertTrue(presenter.presented.isEmpty, "today a manager set before the scene connected is never shown")
    }

    func test_managerSetToNil_afterConnect_presentsNothing() {
        let (sut, presenter) = makeSUT()
        sut.sceneDidConnect(presenter: presenter)

        sut.loadingManagerDidChange(to: DMLoadingManagerMain?.none)

        XCTAssertTrue(presenter.presented.isEmpty, "no manager, no HUD")
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
