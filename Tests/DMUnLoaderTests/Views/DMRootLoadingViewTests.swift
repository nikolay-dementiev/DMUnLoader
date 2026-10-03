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
            evaluations.values.append(manager)
            return Color.clear
        }
        .environmentObject(sceneDelegate)
        ViewHosting.host(view: sut)
        defer { ViewHosting.expel() }
        let evaluationsBefore = settledCount(of: evaluations)

        evaluations.values.first?.showLoading(provider: DefaultDMLoadingViewProvider())

        XCTAssertTrue(
            waitUntil { evaluations.values.count > evaluationsBefore },
            "a change of the manager the view created evaluates the content again"
        )
    }

    // MARK: - Injected manager

    func test_injectedInit_withoutASceneDelegateInTheEnvironment_givesTheContentTheInjectedManager() {
        let injected = DMLoadingManagerMain()
        let evaluations = Managers()
        let sut = DMRootLoadingView(manager: injected) { (manager: DMLoadingManagerMain) -> Color in
            evaluations.values.append(manager)
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
            evaluations.values.append(manager)
            return Color.clear
        }
        ViewHosting.host(view: sut)
        defer { ViewHosting.expel() }
        let evaluationsBefore = settledCount(of: evaluations)

        injected.showLoading(provider: DefaultDMLoadingViewProvider())

        XCTAssertTrue(
            waitUntil { evaluations.values.count > evaluationsBefore },
            "a change of the injected manager evaluates the content again"
        )
    }

    // MARK: - Helpers

    private final class Managers {
        var values: [DMLoadingManagerMain] = []
    }

    /// The count once no evaluation came for a moment: SwiftUI evaluates a view it starts
    /// to host more than once.
    private func settledCount(of evaluations: Managers) -> Int {
        _ = waitUntil { !evaluations.values.isEmpty }
        let deadline = Date().addingTimeInterval(TestTiming.callbackAllowance)
        var count = evaluations.values.count
        while Date() < deadline {
            RunLoop.current.run(until: Date().addingTimeInterval(0.3))
            guard evaluations.values.count != count else {
                break
            }
            count = evaluations.values.count
        }
        return count
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
