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

        XCTAssertEqual(waitForReports(fixture.reports, count: 1), [false], "the window learns at once that no HUD is shown")
    }

    func test_appearance_whileLoading_reportsThatAHUDIsShown() {
        let fixture = makeSUT(initialState: .loading(provider: Self.provider))
        ViewHosting.host(view: fixture.sut)
        defer { ViewHosting.expel() }

        XCTAssertEqual(waitForReports(fixture.reports, count: 1), [true], "the window learns at once that a HUD is shown")
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
            [false, true, false],
            "the window learns when the HUD appears and when it goes"
        )
    }

    // MARK: - What is drawn

    func test_noState_drawsNothing() throws {
        let manager = DMLoadingManagerMain(state: .none, settings: Self.settings)

        let image = render(DMHudSceneView(loadingManager: manager), until: { _ in false })

        XCTAssertEqual(try maximumAlpha(of: image), 0, "without a state the HUD window shows the app through it")
    }

    func test_loading_drawsTheHUDOverTheCentre() throws {
        let manager = DMLoadingManagerMain(state: .loading(provider: Self.provider), settings: Self.settings)

        let image = render(DMHudSceneView(loadingManager: manager), until: { (try? self.centreAlpha(of: $0)) ?? 0 > 0 })

        XCTAssertGreaterThan(try centreAlpha(of: image), 0, "the loading HUD is drawn over the centre of the screen")
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
        var values: [Bool] = []
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

    /// Turns the run loop until `count` reports arrived or the callback allowance passed.
    private func waitForReports(_ reports: Reports, count: Int) -> [Bool] {
        let deadline = Date().addingTimeInterval(TestTiming.callbackAllowance)
        while reports.values.count < count, Date() < deadline {
            RunLoop.current.run(until: Date().addingTimeInterval(0.02))
        }
        return reports.values
    }

    /// Renders `view` in a window with a clear background, the way the HUD window shows it,
    /// once `done` holds for a rendering or after half a second.
    private func render(_ view: some View, until done: (UIImage) -> Bool) -> UIImage {
        let controller = UIHostingController(rootView: view)
        controller.view.backgroundColor = .clear
        let window = UIWindow(frame: CGRect(x: 0, y: 0, width: 200, height: 300))
        window.rootViewController = controller
        window.isHidden = false
        defer { window.isHidden = true }
        let format = UIGraphicsImageRendererFormat()
        format.scale = 1
        let renderer = UIGraphicsImageRenderer(bounds: controller.view.bounds, format: format)
        let deadline = Date().addingTimeInterval(0.5)
        var image = UIImage()
        repeat {
            RunLoop.current.run(until: Date().addingTimeInterval(0.05))
            image = renderer.image { context in
                controller.view.layer.render(in: context.cgContext)
            }
        } while !done(image) && Date() < deadline
        return image
    }

    private struct Alphas {
        let values: [UInt8]
        let width: Int
        let height: Int
    }

    private func alphas(of image: UIImage) throws -> Alphas {
        let cgImage = try XCTUnwrap(image.cgImage, "the rendering has a bitmap")
        let width = cgImage.width
        let height = cgImage.height
        var pixels = [UInt8](repeating: 0, count: width * height * 4)
        let context = try XCTUnwrap(
            CGContext(
                data: &pixels,
                width: width,
                height: height,
                bitsPerComponent: 8,
                bytesPerRow: width * 4,
                space: CGColorSpaceCreateDeviceRGB(),
                bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue
            ),
            "a bitmap context for the rendering"
        )
        context.draw(cgImage, in: CGRect(x: 0, y: 0, width: width, height: height))
        return Alphas(values: stride(from: 3, to: pixels.count, by: 4).map { pixels[$0] }, width: width, height: height)
    }

    private func maximumAlpha(of image: UIImage) throws -> UInt8 {
        try alphas(of: image).values.max() ?? 0
    }

    private func centreAlpha(of image: UIImage) throws -> UInt8 {
        let alphas = try alphas(of: image)
        return alphas.values[(alphas.height / 2) * alphas.width + alphas.width / 2]
    }
}
