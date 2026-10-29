//
//  DMUnLoader
//
//  Created by Mykola Dementiev
//

import OSLog
import SwiftUI
import ViewInspector
import XCTest
import os
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
        let manager = makeManager(
            state: state,
            settings: DMLoadingManagerDefaultSettings(autoHideDelay: .seconds(600), onBackdropFailure: { spy.record($0) })
        )

        host(manager)
        defer { ViewHosting.expel() }
        waitUntil(!spy.received.isEmpty)
        turnTheRunLoop(for: 0.5)

        XCTAssertEqual(spy.received, [.invalidConfiguration], "the host is told once, in the type of the library")
        XCTAssertEqual(manager.loadableState, state, "the state of the HUD, its retry action included, is the one it was")

        manager.showLoading(provider: Self.provider())
        turnTheRunLoop(for: 0.5)

        XCTAssertEqual(spy.received.count, 1, "a new render with the same values does not report the same failure again")
    }

    // MARK: - How often

    func test_backdropFailure_eachAppearanceOfTheHUD_reportsAgain() {
        let spy = BackdropFailureSpy()
        let manager = makeManager(
            state: .loading(provider: Self.provider()),
            settings: DMLoadingManagerDefaultSettings(autoHideDelay: .seconds(600), onBackdropFailure: { spy.record($0) })
        )

        host(manager)
        defer { ViewHosting.expel() }
        waitUntil(spy.received.count == 1)
        turnTheRunLoop(for: 0.3)
        manager.hide()
        turnTheRunLoop(for: 0.3)
        manager.showLoading(provider: Self.provider())
        waitUntil(spy.received.count == 2)
        turnTheRunLoop(for: 0.5)

        XCTAssertEqual(
            spy.received,
            [.invalidConfiguration, .invalidConfiguration],
            "the HUD makes a new blur view each time it appears, and the host is told for each"
        )
    }

    func test_backdropFailure_handlerThatIsNewAtEveryRead_reportsOnceWhileTheHUDStays() {
        let spy = BackdropFailureSpy()
        let manager = makeManager(
            state: .loading(provider: Self.provider()),
            settings: HandlerNewAtEveryRead(spy: spy)
        )

        host(manager)
        defer { ViewHosting.expel() }
        waitUntil(!spy.received.isEmpty)
        turnTheRunLoop(for: 0.3)
        manager.showFailure(DMAppError.custom("Failed"), provider: Self.provider())
        turnTheRunLoop(for: 0.5)
        manager.showLoading(provider: Self.provider())
        turnTheRunLoop(for: 0.5)

        XCTAssertEqual(
            spy.received.count,
            1,
            "settings that give a new closure at each render do not make the blur view report again"
        )
    }

    func test_backdropFailure_handlerSetAfterTheFailure_isToldAtTheNextAppearanceOnly() {
        let spy = BackdropFailureSpy()
        let settings = HandlerChangedAfterwards()
        let manager = makeManager(state: .loading(provider: Self.provider()), settings: settings)

        host(manager)
        defer { ViewHosting.expel() }
        turnTheRunLoop(for: 1.5)
        settings.set { spy.record($0) }
        manager.showFailure(DMAppError.custom("Failed"), provider: Self.provider())
        turnTheRunLoop(for: 1.0)
        let toldAtOnce = spy.received

        manager.hide()
        turnTheRunLoop(for: 0.3)
        manager.showLoading(provider: Self.provider())
        waitUntil(!spy.received.isEmpty)
        turnTheRunLoop(for: 0.3)

        XCTAssertEqual(toldAtOnce, [], "a failure that was recorded while the host had no handler is not told afterwards")
        XCTAssertEqual(spy.received, [.invalidConfiguration], "the next appearance of the HUD tells the handler the host set")
    }

    // MARK: - No handler is the behaviour of today

    /// A canary of what DMVariableBlurView does, as much as of DMUnLoader: with no handler its view writes
    /// a line to the log, and with one it does not. The wait for a line is a poll, for the absence of one
    /// it is a fixed time, and a leaf that renames its subsystem turns this test red.
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

        XCTAssertFalse(withoutHandler.isEmpty, "no handler of the host: the blur view writes a line to the log, as before")
        XCTAssertTrue(withHandler.isEmpty, "a handler of the host replaces the line of the blur view: \(withHandler)")
    }

    // MARK: - Nothing else reports

    func test_backdropFailure_otherBackdropsAndReduceTransparency_reportNothing() {
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

    private func makeManager(state: DMLoadableType, settings: any DMLoadingManagerSettings) -> DMLoadingManagerMain {
        let manager = DMLoadingManagerMain(state: state, settings: settings)
        trackForMemoryLeaks(manager)
        return manager
    }

    /// ViewInspector pairs `host` and `expel` by the name of the function that calls them, so the name of
    /// the test is passed on: hosted under the name of this helper, the window would never be expelled.
    private func host(_ manager: DMLoadingManagerMain, function: String = #function) {
        ViewHosting.host(view: DMHudSceneView(loadingManager: manager, blurValues: Self.rejectedBlur), function: function)
    }

    /// What the host is told while the HUD of `backdrop` is hosted with a blur that fails.
    private func reports(of backdrop: DMHUDBackdrop, reducesTransparency: Bool) -> [DMHUDBackdropFailure] {
        let spy = BackdropFailureSpy()
        let manager = makeManager(
            state: .loading(provider: Self.provider()),
            settings: DMLoadingManagerDefaultSettings(
                autoHideDelay: .seconds(600),
                backdrop: backdrop,
                onBackdropFailure: { spy.record($0) }
            )
        )

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
        let manager = makeManager(state: .loading(provider: Self.provider()), settings: settings)

        host(manager)
        defer { ViewHosting.expel() }
        let deadline = Date().addingTimeInterval(expectingALine ? 6 : 3)
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

/// Settings of a host that write their own handler: a new closure each time the property is read.
private struct HandlerNewAtEveryRead: DMLoadingManagerSettings {
    let autoHideDelay: Duration = .seconds(600)
    let spy: BackdropFailureSpy

    var onBackdropFailure: (@MainActor @Sendable (DMHUDBackdropFailure) -> Void)? {
        { [spy] in spy.record($0) }
    }
}

/// Settings whose handler the host sets after the HUD is up.
private final class HandlerChangedAfterwards: DMLoadingManagerSettings, Sendable {
    let autoHideDelay: Duration = .seconds(600)
    private let handler = OSAllocatedUnfairLock<(@MainActor @Sendable (DMHUDBackdropFailure) -> Void)?>(initialState: nil)

    var onBackdropFailure: (@MainActor @Sendable (DMHUDBackdropFailure) -> Void)? {
        handler.withLock { $0 }
    }

    func set(_ newHandler: (@MainActor @Sendable (DMHUDBackdropFailure) -> Void)?) {
        handler.withLock { $0 = newHandler }
    }
}
