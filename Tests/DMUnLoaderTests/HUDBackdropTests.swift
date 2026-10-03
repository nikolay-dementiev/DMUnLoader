//
//  DMUnLoader
//
//  Created by Mykola Dementiev
//

import SwiftUI
import ViewInspector
import XCTest
import DMUnLoader
import DMVariableBlurView

/// What the HUD draws behind its card, as the settings of its loading manager choose it.
@MainActor
final class HUDBackdropTests: XCTestCase {

    // MARK: - Settings

    func test_settings_withoutBackdrop_useTheVariableBlur() {
        guard case .variableBlur = DelayOnlySettings().backdrop.kind else {
            return XCTFail("a settings type that sets only the delay keeps the backdrop of every release so far")
        }
    }

    func test_defaultSettings_storeTheirBackdrop() {
        guard case .clear = DMLoadingManagerDefaultSettings(backdrop: .clear).backdrop.kind else {
            return XCTFail("the default settings keep the given backdrop")
        }
        guard case .variableBlur = DMLoadingManagerDefaultSettings().backdrop.kind else {
            return XCTFail("the default settings keep the variable blur when none is given")
        }
    }

    // MARK: - What is drawn

    func test_hudScene_defaultBackdrop_drawsTheBlurWithTheReleasedValues() throws {
        let blur = try makeSUT(backdrop: nil).inspect().find(DMVariableBlurView.self).actualView()

        XCTAssertEqual(
            Mirror(reflecting: blur).descendant("maxBlurRadius") as? CGFloat,
            4,
            "the blur keeps its radius of 4 points"
        )
        XCTAssertEqual(
            String(describing: Mirror(reflecting: blur).descendant("direction").map { $0 } ?? "none"),
            String(describing: DMVariableBlurDirection.blurredCenterClearTopBottom(centerBandProportion: 0.4)),
            "the blur keeps its band of 0.4 across the middle"
        )
    }

    func test_hudScene_otherBackdrops_drawNoBlur() throws {
        for backdrop in [DMHUDBackdrop.clear, .dim(), .material()] {
            XCTAssertThrowsError(
                try makeSUT(backdrop: backdrop).inspect().find(DMVariableBlurView.self),
                "\(backdrop.kind) creates no variable blur"
            )
        }
    }

    func test_hudScene_dimBackdrop_drawsTheGivenColour() throws {
        let colour = Color.red.opacity(0.3)

        XCTAssertNoThrow(
            try makeSUT(backdrop: .dim(colour)).inspect().find(ViewType.Color.self, where: { try $0.value() == colour }),
            "the dim backdrop draws the colour of the settings"
        )
    }

    func test_hudScene_clearBackdrop_drawsNoDim() throws {
        // The dim before the fade: black at no opacity.
        let dim = Color.black.opacity(0)

        XCTAssertNoThrow(
            try makeSUT(backdrop: nil).inspect().find(ViewType.Color.self, where: { try $0.value() == dim }),
            "the default backdrop draws the black dim"
        )
        XCTAssertThrowsError(
            try makeSUT(backdrop: .clear).inspect().find(ViewType.Color.self, where: { try $0.value() == dim }),
            "the clear backdrop draws no dim"
        )
    }

    // MARK: - Helpers

    /// The HUD scene of a failure, with the backdrop of the settings; `nil` keeps the default.
    private func makeSUT(backdrop: DMHUDBackdrop?) -> DMHudSceneView<DMLoadingManagerMain> {
        let settings = backdrop.map { DMLoadingManagerDefaultSettings(autoHideDelay: .seconds(600), backdrop: $0) }
            ?? DMLoadingManagerDefaultSettings(autoHideDelay: .seconds(600))
        let provider = DefaultDMLoadingViewProvider().eraseToAnyViewProvider()
        let manager = DMLoadingManagerMain(
            state: .failure(error: DMAppError.custom("failed"), provider: provider),
            settings: settings
        )
        trackForMemoryLeaks(manager)
        return DMHudSceneView(loadingManager: manager)
    }
}

private struct DelayOnlySettings: DMLoadingManagerSettings {
    let autoHideDelay: Duration = .seconds(2)
}
