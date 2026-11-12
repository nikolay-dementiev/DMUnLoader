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
        // One provider for both states: a provider's identity is part of the state's equality.
        let provider = DefaultDMLoadingViewProvider().eraseToAnyViewProvider()
        let first = DMLoadableType.failure(error: DMAppError.custom("first"), provider: provider, onRetry: nil)
        let second = DMLoadableType.failure(error: DMAppError.custom("second"), provider: provider, onRetry: nil)
        let fixture = makeSUT(initialState: first)
        ViewHosting.host(view: fixture.sut)
        defer { ViewHosting.expel() }
        _ = waitForStates(fixture.reports, count: 1)

        fixture.manager.showFailure(DMAppError.custom("second"), provider: provider)

        XCTAssertEqual(
            waitForStates(fixture.reports, count: 2),
            [first, second],
            "the window learns the second failure as a state of its own, not only as another failure phase"
        )
    }

    // MARK: - How states reach the window
    //
    // Each test ends with a sentinel: a state no other write of the test makes, written after the writes
    // under test, and waited for. A delivery that is late or doubled would come before it, so the list a
    // test asserts is the complete list of what the window was told.

    func test_stateChanges_inOneTurn_reportOnlyTheLastState() {
        let fixture = makeSUT()
        ViewHosting.host(view: fixture.sut)
        defer { ViewHosting.expel() }
        _ = waitForStates(fixture.reports, count: 1)
        let provider = Self.provider

        fixture.manager.showLoading(provider: provider)
        fixture.manager.showFailure(DMAppError.custom("burst"), provider: provider)
        fixture.manager.showSuccess("Saved", provider: provider)
        _ = waitForStates(fixture.reports, count: 2)
        Self.writeSentinel(to: fixture.manager, provider: provider)
        let reported = waitForSentinel(in: fixture.reports, provider: provider)

        XCTAssertEqual(
            reported,
            [DMLoadableType.none, .success("Saved", provider: provider), Self.sentinel(provider)],
            "three writes in one turn reach the window as the last of them, and nothing in between"
        )
    }

    func test_equalStateSetAgain_reportsNothingMore() {
        let provider = Self.provider
        let shown = DMLoadableType.success("Saved", provider: provider)
        let fixture = makeSUT(initialState: shown)
        ViewHosting.host(view: fixture.sut)
        defer { ViewHosting.expel() }
        _ = waitForStates(fixture.reports, count: 1)

        fixture.manager.showSuccess("Saved", provider: provider)
        settle()
        Self.writeSentinel(to: fixture.manager, provider: provider)
        let reported = waitForSentinel(in: fixture.reports, provider: provider)

        XCTAssertEqual(reported, [shown, Self.sentinel(provider)], "an equal state is not told to the window again")
    }

    func test_stateThatLeavesAndReturnsInOneTurn_reportsNothing() {
        let provider = Self.provider
        let shown = DMLoadableType.success("Saved", provider: provider)
        let fixture = makeSUT(initialState: shown)
        ViewHosting.host(view: fixture.sut)
        defer { ViewHosting.expel() }
        _ = waitForStates(fixture.reports, count: 1)

        fixture.manager.showLoading(provider: provider)
        fixture.manager.showSuccess("Saved", provider: provider)
        settle()
        Self.writeSentinel(to: fixture.manager, provider: provider)
        let reported = waitForSentinel(in: fixture.reports, provider: provider)

        XCTAssertEqual(reported, [shown, Self.sentinel(provider)], "a state that left and came back in one turn was never told")
    }

    func test_customManager_notifyingBeforeItChangesItsState_reportsTheCommittedState() {
        let fixture = makeHostSUT()
        ViewHosting.host(view: fixture.sut)
        defer { ViewHosting.expel() }
        _ = waitForStates(fixture.reports, count: 1)
        let provider = Self.provider
        let loading = DMLoadableType.loading(provider: provider)

        fixture.manager.set(loading)
        _ = waitForStates(fixture.reports, count: 2)
        fixture.manager.set(Self.sentinel(provider))
        let reported = waitForSentinel(in: fixture.reports, provider: provider)

        XCTAssertEqual(
            reported,
            [DMLoadableType.none, loading, Self.sentinel(provider)],
            "a manager that announces before it changes is told to the window with the state it ended in"
        )
    }

    func test_customManager_notifyingWithoutAChange_reportsNothing() {
        let fixture = makeHostSUT()
        ViewHosting.host(view: fixture.sut)
        defer { ViewHosting.expel() }
        _ = waitForStates(fixture.reports, count: 1)
        let provider = Self.provider

        fixture.manager.announceWithoutChange()
        settle()
        fixture.manager.set(Self.sentinel(provider))
        let reported = waitForSentinel(in: fixture.reports, provider: provider)

        XCTAssertEqual(
            reported,
            [DMLoadableType.none, Self.sentinel(provider)],
            "an announcement with no change behind it tells the window nothing"
        )
    }

    // MARK: - What is drawn

    func test_noState_drawsNothing() throws {
        let manager = DMLoadingManagerMain(state: .none, settings: Self.settings)
        let reports = Reports()

        // The view reports when it has appeared, so an empty rendering is the view's own, not
        // a view that was never drawn.
        let image = render(
            DMHudSceneView(loadingManager: manager, viewModel: hudViewModel(of: manager)) { reports.values.append($0) },
            for: TestTiming.callbackAllowance,
            until: { _ in !reports.values.isEmpty }
        )

        XCTAssertEqual(reports.values, [.none], "the view appeared, and reported that no HUD is shown")
        XCTAssertEqual(try RenderedAlphas(of: image).maximum, 0, "without a state the HUD window shows the app through it")
    }

    func test_loading_drawsTheHUDOverTheCentre() throws {
        let manager = DMLoadingManagerMain(state: .loading(provider: Self.provider), settings: Self.settings)

        let image = render(
            DMHudSceneView(loadingManager: manager, viewModel: hudViewModel(of: manager)),
            for: TestTiming.callbackAllowance,
            until: { (try? RenderedAlphas(of: $0).centre) ?? 0 > 0 }
        )

        XCTAssertGreaterThan(try RenderedAlphas(of: image).centre, 0, "the loading HUD is drawn over the centre of the screen")
    }

    // MARK: - Buttons

    func test_closeOnAFailure_hidesTheHUD() throws {
        let manager = DMLoadingManagerMain(state: .none, settings: Self.settings)
        manager.showFailure(DMAppError.custom("failed"), provider: DefaultDMLoadingViewProvider(), onRetry: nil)

        try DMHudSceneView(loadingManager: manager, viewModel: hudViewModel(of: manager)).inspect().find(button: "Close").tap()

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

        try DMHudSceneView(loadingManager: manager, viewModel: hudViewModel(of: manager)).inspect().find(button: "Retry").tap()

        XCTAssertEqual(retries.count, 1, "Retry runs the retry action of the failure")
    }

    func test_errorView_evaluatedAgain_receivesANewCloseCommandEachTime() {
        let provider = RecordingErrorProvider()
        let erased = provider.eraseToAnyViewProvider()
        let retry = DMButtonAction {}
        let error = DMAppError.custom("failed")
        let manager = DMLoadingManagerMain(state: .none, settings: Self.settings)
        trackForMemoryLeaks(manager)
        manager.showFailure(error, provider: erased, onRetry: retry)
        ViewHosting.host(view: DMHudSceneView(loadingManager: manager, viewModel: hudViewModel(of: manager)))
        defer { ViewHosting.expel() }
        XCTAssertTrue(
            turnRunLoop(until: !provider.calls.isEmpty, timeout: TestTiming.callbackAllowance),
            "the library asked the provider for the error view within the callback allowance"
        )
        let callsSoFar = provider.calls.count

        // How often SwiftUI evaluates the view is its own business, so the count is not asserted: the
        // test waits until the library has asked again, and compares what it was handed each time.
        manager.showFailure(error, provider: erased, onRetry: retry)
        XCTAssertTrue(
            turnRunLoop(until: provider.calls.count > callsSoFar, timeout: TestTiming.callbackAllowance),
            "the library asked the provider again"
        )

        let closeIDs = provider.calls.map(\.closeID)
        XCTAssertGreaterThanOrEqual(closeIDs.count, 2, "the error view was evaluated more than once")
        XCTAssertEqual(Set(closeIDs).count, closeIDs.count, "every evaluation was handed a Close command of its own")
        XCTAssertEqual(
            Set(provider.calls.map(\.retryID)),
            [retry.id],
            "every evaluation was handed the Retry command of the host, so a repeated id would have shown"
        )
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
        let sut = DMHudSceneView(loadingManager: manager, viewModel: hudViewModel(of: manager)) { reports.values.append($0) }
        trackForMemoryLeaks(manager, file: file, line: line)
        return Fixture(sut: sut, manager: manager, reports: reports)
    }

    /// Turns the run loop until `count` reports arrived or the callback allowance passed, and
    /// returns the phases of the reported states.
    private func waitForReports(
        _ reports: Reports,
        count: Int,
        file: StaticString = #filePath,
        line: UInt = #line
    ) -> [HUDPhase] {
        waitForStates(reports, count: count, file: file, line: line).map(\.phase)
    }

    /// Turns the run loop until `count` reports arrived or the callback allowance passed, and
    /// returns the reported states themselves.
    private func waitForStates(
        _ reports: Reports,
        count: Int,
        file: StaticString = #filePath,
        line: UInt = #line
    ) -> [DMLoadableType] {
        let deadline = Date().addingTimeInterval(TestTiming.callbackAllowance)
        while reports.values.count < count, Date() < deadline {
            RunLoop.current.run(until: Date().addingTimeInterval(0.02))
        }
        XCTAssertGreaterThanOrEqual(
            reports.values.count,
            count,
            "the window reports \(count) state(s) within the callback allowance",
            file: file,
            line: line
        )
        return reports.values
    }

    /// The error of the sentinel, the state a test writes last. Failures with this error are the only states
    /// that carry it.
    private static var sentinelError: DMAppError {
        DMAppError.custom("sentinel")
    }

    private static func sentinel(_ provider: AnyDMLoadingViewProvider) -> DMLoadableType {
        .failure(error: sentinelError, provider: provider, onRetry: nil)
    }

    /// Writes the sentinel to a manager of the library.
    private static func writeSentinel(to manager: DMLoadingManagerMain, provider: AnyDMLoadingViewProvider) {
        manager.showFailure(sentinelError, provider: provider)
    }

    /// Turns the run loop until the last thing the window was told is the sentinel, lets it settle, and returns
    /// everything the window was told.
    private func waitForSentinel(
        in reports: Reports,
        provider: AnyDMLoadingViewProvider,
        file: StaticString = #filePath,
        line: UInt = #line
    ) -> [DMLoadableType] {
        let sentinel = Self.sentinel(provider)
        let deadline = Date().addingTimeInterval(TestTiming.callbackAllowance)
        while reports.values.last != sentinel, Date() < deadline {
            RunLoop.current.run(until: Date().addingTimeInterval(0.02))
        }
        XCTAssertEqual(
            reports.values.last,
            sentinel,
            "the window is told about the sentinel within the callback allowance",
            file: file,
            line: line
        )
        settle()
        return reports.values
    }

    /// Lets the run loop idle for 50 milliseconds, so that SwiftUI commits what was written before the next write.
    /// This is a settle time, not a condition. On a machine so loaded that the commit still did not run, two
    /// writes would reach the view as one, and a test that expects the window to hear nothing would pass without
    /// proving it: a false pass, never a false failure.
    private func settle() {
        RunLoop.current.run(until: Date().addingTimeInterval(0.05))
    }

    private struct HostFixture {
        let sut: DMHudSceneView<HostLoadingManagerSpy>
        let manager: HostLoadingManagerSpy
        let reports: Reports
    }

    /// The view and a manager of the host's own that shows nothing. The test hosts the view itself, as `makeSUT` does.
    private func makeHostSUT(file: StaticString = #filePath, line: UInt = #line) -> HostFixture {
        let manager = HostLoadingManagerSpy()
        let reports = Reports()
        let sut = DMHudSceneView(loadingManager: manager, viewModel: hudViewModel(of: manager)) { reports.values.append($0) }
        trackForMemoryLeaks(manager, file: file, line: line)
        return HostFixture(sut: sut, manager: manager, reports: reports)
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

/// Records the Close and Retry commands that the library hands to the error view, one entry per evaluation.
@MainActor
private final class RecordingErrorProvider: @MainActor DMLoadingViewProvider {
    struct Call {
        let closeID: UUID
        let retryID: UUID?
    }

    private(set) var calls: [Call] = []

    func getErrorView(error: any Error, onRetry: (any DMAction)?, onClose: any DMAction) -> Color {
        calls.append(Call(closeID: onClose.id, retryID: onRetry?.id))
        return Color.clear
    }
}
