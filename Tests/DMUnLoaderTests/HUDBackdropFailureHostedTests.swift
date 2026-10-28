//
//  DMUnLoader
//
//  Created by Mykola Dementiev
//

import OSLog
import SwiftUI
import ViewInspector
import XCTest
import DMUnLoader

/// The failure of the backdrop on the real path: the real blur view of DMVariableBlurView in a real
/// window, made to fail for real with a radius it rejects, since the system of the test offers the
/// effect and no real failure of the effect can be had.
@MainActor
final class HUDBackdropFailureHostedTests: XCTestCase {
    private static let rejectedBlur = HUDBlurValues(maxBlurRadius: -1, centerBandProportion: 0.4)

    // MARK: - The handler of the host reaches the blur view

    func test_backdropFailure_realBlurRejectsItsRadius_reportsOnceWithoutChangingHUDState() {
        let spy = BackdropFailureSpy()
        let state = DMLoadableType.failure(
            error: DMAppError.custom("Failed"),
            provider: Self.provider(),
            onRetry: DMButtonAction {}
        )
        let settings = DMLoadingManagerDefaultSettings(
            autoHideDelay: .seconds(600),
            onBackdropFailure: { spy.record($0) }
        )
        let manager = DMLoadingManagerMain(state: state, settings: settings)
        trackForMemoryLeaks(manager)

        ViewHosting.host(view: DMHudSceneView(loadingManager: manager, blurValues: Self.rejectedBlur))
        defer { ViewHosting.expel() }
        waitUntil(!spy.received.isEmpty)
        turnTheRunLoop(for: 0.5)

        XCTAssertEqual(spy.received, [.invalidConfiguration], "the host is told once, in the type of the library")
        XCTAssertEqual(manager.loadableState, state, "the state of the HUD, its retry action included, is the one it was")
        XCTAssertEqual(manager.settings.hudDismissal, settings.hudDismissal, "the dismissal rules are the ones they were")

        manager.showLoading(provider: Self.provider())
        turnTheRunLoop(for: 0.5)

        XCTAssertEqual(spy.received.count, 1, "a new render with the same values does not report the same failure again")
    }

    // MARK: - No handler is the behaviour of today

    func test_backdropFailure_noHandler_keepsTheLogLineOfTheBlurView_andAHandlerReplacesIt() throws {
        let withoutHandler = try logLinesOfTheBlurView(
            whileHosting: DMLoadingManagerDefaultSettings(autoHideDelay: .seconds(600)),
            expectingALine: true
        )
        let spy = BackdropFailureSpy()
        let withHandler = try logLinesOfTheBlurView(
            whileHosting: DMLoadingManagerDefaultSettings(
                autoHideDelay: .seconds(600),
                onBackdropFailure: { spy.record($0) }
            ),
            expectingALine: false
        )

        XCTAssertEqual(
            withoutHandler.count,
            1,
            "no handler of the host: the blur view writes its line to the log, as before: \(withoutHandler)"
        )
        XCTAssertEqual(withHandler.count, 0, "a handler of the host replaces the line of the blur view: \(withHandler)")
    }

    // MARK: - Nothing else reports

    func test_backdropFailure_onlyTheVariableBlurReports() {
        XCTAssertEqual(
            reports(of: .variableBlur, reducesTransparency: false),
            [.invalidConfiguration],
            "control: the variable blur reports in this harness, so the silences below say something"
        )
        XCTAssertEqual(reports(of: .material(), reducesTransparency: false), [], ".material draws no variable blur")
        XCTAssertEqual(reports(of: .dim(), reducesTransparency: false), [], ".dim draws no variable blur")
        XCTAssertEqual(reports(of: .clear, reducesTransparency: false), [], ".clear draws no variable blur")
        XCTAssertEqual(
            reports(of: .variableBlur, reducesTransparency: true),
            [],
            "under Reduce Transparency the HUD draws no blur"
        )
    }

    // MARK: - Helpers

    private static func provider() -> AnyDMLoadingViewProvider {
        DefaultDMLoadingViewProvider().eraseToAnyViewProvider()
    }

    /// What the host is told while the HUD of `backdrop` is hosted with a blur that fails.
    private func reports(of backdrop: DMHUDBackdrop, reducesTransparency: Bool) -> [DMHUDBackdropFailure] {
        let spy = BackdropFailureSpy()
        let manager = DMLoadingManagerMain(
            state: .loading(provider: Self.provider()),
            settings: DMLoadingManagerDefaultSettings(
                autoHideDelay: .seconds(600),
                backdrop: backdrop,
                onBackdropFailure: { spy.record($0) }
            )
        )
        trackForMemoryLeaks(manager)

        ViewHosting.host(
            view: DMHudSceneView(loadingManager: manager, blurValues: Self.rejectedBlur)
                .environment(\.hudReducesTransparency, reducesTransparency)
        )
        waitUntil(!spy.received.isEmpty)
        turnTheRunLoop(for: 0.5)
        ViewHosting.expel()
        return spy.received
    }

    /// The lines that the blur view of DMVariableBlurView writes to the log of this process while the
    /// HUD of `settings` is hosted with a blur that fails. The first hosting of a process writes its line a
    /// little late, so when a line is expected the wait is for it; when none is, the wait is a fixed time.
    private func logLinesOfTheBlurView(
        whileHosting settings: DMLoadingManagerDefaultSettings,
        expectingALine: Bool
    ) throws -> [String] {
        let marker = Date()
        let manager = DMLoadingManagerMain(state: .loading(provider: Self.provider()), settings: settings)
        trackForMemoryLeaks(manager)

        ViewHosting.host(view: DMHudSceneView(loadingManager: manager, blurValues: Self.rejectedBlur))
        defer { ViewHosting.expel() }
        let deadline = Date().addingTimeInterval(expectingALine ? 4 : 2)
        var lines: [String] = []
        repeat {
            turnTheRunLoop(for: 0.1)
            lines = try blurViewLines(since: marker)
        } while Date() < deadline && !(expectingALine && !lines.isEmpty)
        // A little longer, so that a second line would show.
        turnTheRunLoop(for: 0.5)
        return try blurViewLines(since: marker)
    }

    /// `position(date:)` does not cut the log at the date: the lines of earlier hostings come with it.
    private func blurViewLines(since marker: Date) throws -> [String] {
        let store = try OSLogStore(scope: .currentProcessIdentifier)
        let entries = try store.getEntries(at: store.position(date: marker))
        return entries.compactMap { entry in
            guard let entry = entry as? OSLogEntryLog, entry.subsystem == "DMVariableBlurView", entry.date >= marker else {
                return nil
            }
            return entry.composedMessage
        }
    }

    private func turnTheRunLoop(for seconds: TimeInterval) {
        RunLoop.current.run(until: Date().addingTimeInterval(seconds))
    }

    private func waitUntil(_ condition: @autoclosure () -> Bool) {
        let deadline = Date().addingTimeInterval(TestTiming.callbackAllowance)
        while !condition(), Date() < deadline {
            RunLoop.current.run(until: Date().addingTimeInterval(0.02))
        }
    }
}
