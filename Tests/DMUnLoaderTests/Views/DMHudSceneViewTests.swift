//
//  DMUnLoader
//
//  Created by Mykola Dementiev
//

import SwiftUI
import UIKit
import ViewInspector
import XCTest
import DMUnLoader

/// The view of the HUD window, checked by what a host observes: what the window learns
/// about the HUD, what is drawn, and what the buttons of the HUD do.
@MainActor
final class DMHudSceneViewTests: XCTestCase {

    // MARK: - Reports to the window

    func test_appearance_withNoState_reportsThatNoHUDIsShown() {
        let fixture = makeSUT()
        ViewHosting.host(view: fixture.sut)
        defer { ViewHosting.expel() }

        XCTAssertEqual(waitForReports(fixture.reports, count: 1), [.none], "the window learns at once that no HUD is shown")
    }

    func test_appearance_whileLoading_reportsThatAHUDIsShown() {
        let fixture = makeSUT(initialState: .loading(provider: Self.provider))
        ViewHosting.host(view: fixture.sut)
        defer { ViewHosting.expel() }

        XCTAssertEqual(waitForReports(fixture.reports, count: 1), [.loading], "the window learns at once that a HUD is shown")
    }

    func test_stateChanges_reportEachTurnBetweenNoHUDAndAHUD() {
        let fixture = makeSUT()
        ViewHosting.host(view: fixture.sut)
        defer { ViewHosting.expel() }
        _ = waitForReports(fixture.reports, count: 1)

        fixture.manager.showLoading(provider: DefaultDMLoadingViewProvider())
        _ = waitForReports(fixture.reports, count: 2)
        fixture.manager.hide()

        XCTAssertEqual(
            waitForReports(fixture.reports, count: 3),
            [.none, .loading, .none],
            "the window learns when the HUD appears and when it goes"
        )
    }

    func test_phaseChangesWhileShown_reportEachPhase() {
        let fixture = makeSUT(initialState: .loading(provider: Self.provider))
        ViewHosting.host(view: fixture.sut)
        defer { ViewHosting.expel() }
        _ = waitForReports(fixture.reports, count: 1)

        fixture.manager.showFailure(DMAppError.custom("failed"), provider: DefaultDMLoadingViewProvider())

        XCTAssertEqual(
            waitForReports(fixture.reports, count: 2),
            [.loading, .failure],
            "the window learns that the shown HUD has another phase"
        )
    }

    func test_anotherFailureWhileShown_reportsTheNewState() {
        let fixture = makeSUT(
            initialState: .failure(error: DMAppError.custom("first"), provider: Self.provider, onRetry: nil)
        )
        ViewHosting.host(view: fixture.sut)
        defer { ViewHosting.expel() }
        _ = waitForReports(fixture.reports, count: 1)

        fixture.manager.showFailure(DMAppError.custom("second"), provider: DefaultDMLoadingViewProvider())

        XCTAssertEqual(
            waitForReports(fixture.reports, count: 2),
            [.failure, .failure],
            "the window learns that the shown HUD shows another failure"
        )
    }

    // MARK: - What is drawn

    func test_noState_drawsNothing() throws {
        let manager = DMLoadingManagerMain(state: .none, settings: Self.settings)
        let reports = Reports()

        // The view reports when it has appeared, so an empty rendering is the view's own, not
        // a view that was never drawn.
        let image = render(
            DMHudSceneView(loadingManager: manager) { reports.values.append($0) },
            for: TestTiming.callbackAllowance,
            until: { _ in !reports.values.isEmpty }
        )

        XCTAssertEqual(reports.values, [.none], "the view appeared, and reported that no HUD is shown")
        XCTAssertEqual(try RenderedAlphas(of: image).maximum, 0, "without a state the HUD window shows the app through it")
    }

    func test_loading_drawsTheHUDOverTheCentre() throws {
        let manager = DMLoadingManagerMain(state: .loading(provider: Self.provider), settings: Self.settings)

        let image = render(
            DMHudSceneView(loadingManager: manager),
            for: TestTiming.callbackAllowance,
            until: { (try? RenderedAlphas(of: $0).centre) ?? 0 > 0 }
        )

        XCTAssertGreaterThan(try RenderedAlphas(of: image).centre, 0, "the loading HUD is drawn over the centre of the screen")
    }

    // MARK: - Buttons

    func test_closeOnAFailure_hidesTheHUD() throws {
        let manager = DMLoadingManagerMain(state: .none, settings: Self.settings)
        manager.showFailure(DMAppError.custom("failed"), provider: DefaultDMLoadingViewProvider(), onRetry: nil)

        try DMHudSceneView(loadingManager: manager).inspect().find(button: "Close").tap()

        XCTAssertEqual(manager.loadableState, .none, "Close hides the failure HUD")
    }

    func test_retryOnAFailure_runsTheRetryActionOnce() throws {
        let manager = DMLoadingManagerMain(state: .none, settings: Self.settings)
        let retries = Counter()
        manager.showFailure(
            DMAppError.custom("failed"),
            provider: DefaultDMLoadingViewProvider(),
            onRetry: DMButtonAction { retries.count += 1 }
        )

        try DMHudSceneView(loadingManager: manager).inspect().find(button: "Retry").tap()

        XCTAssertEqual(retries.count, 1, "Retry runs the retry action of the failure")
    }

    // MARK: - Helpers

    /// A delay no test reaches, so a HUD never hides by itself during a test.
    private static var settings: StubDMLoadingManagerSettings {
        StubDMLoadingManagerSettings(autoHideDelay: .seconds(600))
    }

    private static var provider: AnyDMLoadingViewProvider {
        DefaultDMLoadingViewProvider().eraseToAnyViewProvider()
    }

    private final class Counter {
        var count = 0
    }

    private final class Reports {
        var values: [DMLoadableType] = []
    }

    private struct Fixture {
        let sut: DMHudSceneView<DMLoadingManagerMain>
        let manager: DMLoadingManagerMain
        let reports: Reports
    }

    /// The view and the manager it shows. The test hosts the view itself and expels it
    /// before returning, so the leak check after the test finds the manager released.
    private func makeSUT(
        initialState: DMLoadableType = .none,
        file: StaticString = #filePath,
        line: UInt = #line
    ) -> Fixture {
        let manager = DMLoadingManagerMain(state: initialState, settings: Self.settings)
        let reports = Reports()
        let sut = DMHudSceneView(loadingManager: manager) { reports.values.append($0) }
        trackForMemoryLeaks(manager, file: file, line: line)
        return Fixture(sut: sut, manager: manager, reports: reports)
    }

    /// Turns the run loop until `count` reports arrived or the callback allowance passed, and
    /// returns the phases of the reported states.
    private func waitForReports(_ reports: Reports, count: Int) -> [HUDPhase] {
        let deadline = Date().addingTimeInterval(TestTiming.callbackAllowance)
        while reports.values.count < count, Date() < deadline {
            RunLoop.current.run(until: Date().addingTimeInterval(0.02))
        }
        XCTAssertGreaterThanOrEqual(
            reports.values.count,
            count,
            "the window reports \(count) state(s) within the callback allowance"
        )
        return reports.values.map(\.phase)
    }

    /// Renders `view` in a window with a clear background, the way the HUD window shows it,
    /// once `done` holds for a rendering or after `seconds`, so a test returns as soon as
    /// what it waits for has happened.
    private func render(_ view: some View, for seconds: Double, until done: (UIImage) -> Bool) -> UIImage {
        let controller = UIHostingController(rootView: view)
        controller.view.backgroundColor = .clear
        let window = UIWindow(frame: CGRect(x: 0, y: 0, width: 200, height: 300))
        window.rootViewController = controller
        window.isHidden = false
        defer { window.isHidden = true }
        let deadline = Date().addingTimeInterval(seconds)
        var image = UIImage()
        repeat {
            RunLoop.current.run(until: Date().addingTimeInterval(0.05))
            image = controller.view.renderedLayers()
        } while !done(image) && Date() < deadline
        return image
    }
}
