//
//  DMUnLoader
//
//  Created by Mykola Dementiev
//

import DMVariableBlurView
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

    /// The hard check: a host with no handler gives the blur view none, so that the blur view keeps writing
    /// its own line to the log. It reads the view that the HUD makes and needs no log.
    func test_backdropFailure_hostWithoutHandler_givesTheBlurViewNoHandler() throws {
        let blur = try blurViewOfTheHUD(settings: DMLoadingManagerDefaultSettings(autoHideDelay: .seconds(600)))

        XCTAssertFalse(
            hasFailureHandler(blur),
            "no handler of the host: the blur view has none, and keeps writing its own line to the log"
        )
    }

    /// The control of the check above: the same read finds a handler when the host has one.
    func test_backdropFailure_hostWithHandler_givesTheBlurViewOne() throws {
        let spy = BackdropFailureSpy()
        let blur = try blurViewOfTheHUD(
            settings: DMLoadingManagerDefaultSettings(autoHideDelay: .seconds(600), onBackdropFailure: { spy.record($0) })
        )

        XCTAssertTrue(
            hasFailureHandler(blur),
            "a handler of the host: the blur view has one, so the read of the check above can see a handler"
        )
    }

    /// A canary of what DMVariableBlurView does, as much as of DMUnLoader: with no handler its view writes
    /// a line to the log, and with one it does not. A leaf that renames its subsystem turns this test red.
    /// It reads a log, which a hosted runner may not give: the test first writes a line of its own and reads
    /// it back, and when it cannot, it checks nothing and says so in the result bundle. It does not skip: the
    /// CI job of the package fails on any skipped test.
    func test_backdropFailure_noHandler_keepsTheLogLineOfTheBlurView_andAHandlerReplacesIt() throws {
        switch try runLogCanary(reading: Self.readTheLogOfThisProcess) {
        case let .checked(withoutHandler, withHandler):
            XCTAssertFalse(
                withoutHandler.isEmpty,
                "no handler of the host: the blur view writes a line to the log, as before"
            )
            XCTAssertTrue(withHandler.isEmpty, "a handler of the host replaces the line of the blur view: \(withHandler)")
        case .unreadable:
            noteThatTheLogCannotBeRead()
        }
    }

    func test_backdropFailure_logCanary_logThatCannotBeRead_isUnreadableAndChecksNothing() throws {
        let result = try runLogCanary(reading: { _ in [] }, controlAllowance: 0.5)

        XCTAssertEqual(result, .unreadable, "a log that does not give back the control line is not read for the blur view")
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

    /// The view that the HUD of `settings` makes for the blur, found without hosting it: nothing fails and
    /// nothing is logged.
    private func blurViewOfTheHUD(settings: DMLoadingManagerDefaultSettings) throws -> DMVariableBlurView {
        let manager = makeManager(state: .loading(provider: Self.provider()), settings: settings)
        return try DMHudSceneView(loadingManager: manager).inspect().find(DMVariableBlurView.self).actualView()
    }

    /// Whether the blur view has a handler of failures. `DMVariableBlurView` keeps it in a private stored
    /// property, which is read by name: a leaf that renames it fails the test that asks, and does not
    /// answer `false`.
    private func hasFailureHandler(
        _ view: DMVariableBlurView,
        file: StaticString = #filePath,
        line: UInt = #line
    ) -> Bool {
        guard let property = Mirror(reflecting: view).children.first(where: { $0.label == "failureHandler" }) else {
            XCTFail("DMVariableBlurView has no stored property failureHandler, which this check reads", file: file, line: line)
            return false
        }
        return !Mirror(reflecting: property.value).children.isEmpty
    }

    /// One line of the unified log.
    private struct LoggedLine {
        let subsystem: String
        let message: String
    }

    /// What the log canary found.
    private enum LogCanaryResult: Equatable {
        case checked(withoutHandler: [String], withHandler: [String])
        case unreadable
    }

    private static let controlSubsystem = "DMUnLoaderTests.LogControl"

    /// The lines that the unified log of this process holds from `marker` on. `position(date:)` does not cut
    /// the log at the date: the lines of earlier hostings come with it.
    private static func readTheLogOfThisProcess(_ marker: Date) throws -> [LoggedLine] {
        let store = try OSLogStore(scope: .currentProcessIdentifier)
        return try store.getEntries(at: store.position(date: marker)).compactMap { entry in
            guard let entry = entry as? OSLogEntryLog, entry.date >= marker else {
                return nil
            }
            return LoggedLine(subsystem: entry.subsystem, message: entry.composedMessage)
        }
    }

    /// Writes a line of its own to the log and waits for `read` to give it back. Returns how long that took,
    /// or `nil` when the line did not come within `allowance`.
    private func latencyOfTheControlLine(
        reading read: (Date) throws -> [LoggedLine],
        allowance: TimeInterval
    ) throws -> TimeInterval? {
        let marker = Date()
        let token = UUID().uuidString
        Logger(subsystem: Self.controlSubsystem, category: "control").notice("control line \(token, privacy: .public)")
        repeat {
            turnTheRunLoop(for: 0.1)
            let lines = try read(marker)
            if lines.contains(where: { $0.subsystem == Self.controlSubsystem && $0.message.contains(token) }) {
                return Date().timeIntervalSince(marker)
            }
        } while Date().timeIntervalSince(marker) < allowance
        return nil
    }

    /// Hosts the HUD of a manager with no handler and then of one with a handler, each with a blur that fails,
    /// and gives the lines of the blur view in the log of each, once the log has been shown to give back a line.
    ///
    /// A line is waited for with a long allowance, since a slow runner writes it late and the wait ends when it
    /// comes. The absence of a line is judged only after the handler of the host has been told: the blur view
    /// has then dealt with the failure, and one more wait, as long as the control line took to be read, lets a
    /// line show.
    private func runLogCanary(
        reading read: @escaping (Date) throws -> [LoggedLine],
        controlAllowance: TimeInterval = 10
    ) throws -> LogCanaryResult {
        guard let latency = try latencyOfTheControlLine(reading: read, allowance: controlAllowance) else {
            return .unreadable
        }
        let started = Date()
        let withoutHandler = try linesOfTheBlurView(
            whileHosting: DMLoadingManagerDefaultSettings(autoHideDelay: .seconds(600)),
            toldBy: nil,
            settleFor: 0.5,
            reading: read
        )
        let lineAfter = Date().timeIntervalSince(started)
        let spy = BackdropFailureSpy()
        let withHandler = try linesOfTheBlurView(
            whileHosting: DMLoadingManagerDefaultSettings(
                autoHideDelay: .seconds(600),
                onBackdropFailure: { spy.record($0) }
            ),
            toldBy: spy,
            settleFor: latency + 0.5,
            reading: read
        )
        let diagnostics = XCTAttachment(
            string: "control line read after \(latency) s; hosting without a handler, line and settling took \(lineAfter) s"
        )
        diagnostics.lifetime = .keepAlways
        add(diagnostics)
        return .checked(withoutHandler: withoutHandler, withHandler: withHandler)
    }

    private func linesOfTheBlurView(
        whileHosting settings: DMLoadingManagerDefaultSettings,
        toldBy spy: BackdropFailureSpy?,
        settleFor settling: TimeInterval,
        reading read: (Date) throws -> [LoggedLine]
    ) throws -> [String] {
        let marker = Date()
        let manager = makeManager(state: .loading(provider: Self.provider()), settings: settings)

        host(manager)
        defer { ViewHosting.expel() }
        let deadline = Date().addingTimeInterval(Self.longAllowance)
        var lines: [String] = []
        repeat {
            turnTheRunLoop(for: 0.1)
            lines = try read(marker).filter { $0.subsystem == "DMVariableBlurView" }.map(\.message)
        } while Date() < deadline && (spy.map { $0.received.isEmpty } ?? lines.isEmpty)
        turnTheRunLoop(for: settling)
        return try read(marker).filter { $0.subsystem == "DMVariableBlurView" }.map(\.message)
    }

    private func noteThatTheLogCannotBeRead() {
        let name = "The unified log cannot be read here: the line of the blur view was not checked"
        XCTContext.runActivity(named: name) { activity in
            let note = XCTAttachment(
                string: "A line that this test wrote to the log of its own process was not read back, so this log cannot"
                    + " tell whether the blur view wrote a line. The hard checks of the handler of the blur view ran."
            )
            note.lifetime = .keepAlways
            activity.add(note)
        }
    }

    /// How long a line of a slow runner may take to show, and how long the HUD may take to deal with a failure.
    private static let longAllowance: TimeInterval = 30

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
