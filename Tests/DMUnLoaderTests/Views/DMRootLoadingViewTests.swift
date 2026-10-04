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
/// hosted with one as its environment object. With an injected manager the view reads no
/// environment object: those tests host it without one, and a read would stop the run.
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

    func test_releasedInit_managerChange_evaluatesTheContentAgain() {
        let sceneDelegate = DMSceneDelegateBase<DMLoadingManagerMain>()
        let evaluations = Managers()
        trackForMemoryLeaks(sceneDelegate)
        let sut = DMRootLoadingView { (manager: DMLoadingManagerMain) -> Color in
            evaluations.record(manager)
            return Color.clear
        }
        .environmentObject(sceneDelegate)
        ViewHosting.host(view: sut)
        defer { ViewHosting.expel() }
        XCTAssertTrue(
            waitUntil { !evaluations.values.isEmpty },
            "the content is evaluated once the view is hosted"
        )

        evaluations.values.first?.showLoading(provider: DefaultDMLoadingViewProvider())

        XCTAssertTrue(
            waitUntil { evaluations.lastSawLoading },
            "the last evaluation of the content saw the loading state of its manager"
        )
    }

    // MARK: - Injected manager

    func test_injectedInit_withoutASceneDelegateInTheEnvironment_givesTheContentTheInjectedManager() {
        let injected = DMLoadingManagerMain()
        let evaluations = Managers()
        let sut = DMRootLoadingView(manager: injected) { (manager: DMLoadingManagerMain) -> Color in
            evaluations.record(manager)
            return Color.clear
        }
        ViewHosting.host(view: sut)
        defer { ViewHosting.expel() }

        let shown = waitUntil { !evaluations.values.isEmpty }

        XCTAssertTrue(shown, "the content is shown with no scene delegate in the environment")
        XCTAssertTrue(
            evaluations.values.allSatisfy { $0 === injected },
            "the content gets the injected manager, not one the view creates"
        )
    }

    func test_injectedInit_managerChange_evaluatesTheContentAgain() {
        let injected = DMLoadingManagerMain()
        let evaluations = Managers()
        let sut = DMRootLoadingView(manager: injected) { (manager: DMLoadingManagerMain) -> Color in
            evaluations.record(manager)
            return Color.clear
        }
        ViewHosting.host(view: sut)
        defer { ViewHosting.expel() }
        XCTAssertTrue(
            waitUntil { !evaluations.values.isEmpty },
            "the content is evaluated once the view is hosted"
        )

        injected.showLoading(provider: DefaultDMLoadingViewProvider())

        XCTAssertTrue(
            waitUntil { evaluations.lastSawLoading },
            "the last evaluation of the content saw the loading state of the injected manager"
        )
    }

    // MARK: - Helpers

    @MainActor
    private final class Managers {
        var values: [DMLoadingManagerMain] = []
        /// Whether the last evaluation of the content found its manager in a loading state.
        private(set) var lastSawLoading = false

        /// Called by the content on every evaluation, with the manager it was given.
        func record(_ manager: DMLoadingManagerMain) {
            values.append(manager)
            if case .loading = manager.loadableState {
                lastSawLoading = true
            } else {
                lastSawLoading = false
            }
        }
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
