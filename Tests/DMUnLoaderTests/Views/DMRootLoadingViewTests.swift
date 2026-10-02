//
//  DMUnLoader
//
//  Created by Mykola Dementiev
//

import SwiftUI
import ViewInspector
import XCTest
import DMUnLoader

/// The SwiftUI entry point creates the loading manager and hands it to the scene delegate,
/// which shows its HUD. A scene delegate exists without a connected scene, so the view is
/// hosted with one as its environment object.
@MainActor
final class DMRootLoadingViewTests: XCTestCase {

    func test_appearance_handsTheManagerOfTheContentToTheSceneDelegate() {
        let sceneDelegate = DMSceneDelegateBase<DMLoadingManagerMain>()
        let contentManagers = Managers()
        trackForMemoryLeaks(sceneDelegate)
        let sut = DMRootLoadingView { manager in
            Color.clear.onAppear { contentManagers.values.append(manager) }
        }
        .environmentObject(sceneDelegate)
        ViewHosting.host(view: sut)
        defer { ViewHosting.expel() }

        let handedOver = waitUntil { sceneDelegate.loadingManager != nil && !contentManagers.values.isEmpty }

        XCTAssertTrue(handedOver, "the scene delegate gets a manager when the root view appears")
        XCTAssertTrue(
            sceneDelegate.loadingManager === contentManagers.values.first,
            "the scene delegate gets the manager the content shows"
        )
    }

    // MARK: - Helpers

    private final class Managers {
        var values: [DMLoadingManagerMain] = []
    }

    /// Turns the run loop until `condition` holds or the callback allowance passed.
    private func waitUntil(_ condition: () -> Bool) -> Bool {
        let deadline = Date().addingTimeInterval(TestTiming.callbackAllowance)
        while !condition(), Date() < deadline {
            RunLoop.current.run(until: Date().addingTimeInterval(0.02))
        }
        return condition()
    }
}
