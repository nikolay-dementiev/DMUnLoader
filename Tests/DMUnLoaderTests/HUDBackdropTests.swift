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

    // MARK: - Reduce Transparency

    func test_hudScene_reduceTransparency_drawsNoBlur() throws {
        let sut = makeSUT(backdrop: nil).environment(\.hudReducesTransparency, true)
        let dim = Color.black.opacity(0)

        XCTAssertThrowsError(
            try sut.inspect().find(DMVariableBlurView.self),
            "under Reduce Transparency the default backdrop draws no blur"
        )
        XCTAssertNoThrow(
            try sut.inspect().find(ViewType.Color.self, where: { try $0.value() == dim }),
            "under Reduce Transparency the default backdrop keeps its dim"
        )
    }

    func test_hudScene_reduceTransparency_materialBackdrop_drawsTheDim() throws {
        let sut = makeSUT(backdrop: .material()).environment(\.hudReducesTransparency, true)
        let dim = Color.black.opacity(0)

        XCTAssertNoThrow(
            try sut.inspect().find(ViewType.Color.self, where: { try $0.value() == dim }),
            "under Reduce Transparency the material backdrop draws the dim of the default backdrop"
        )
        XCTAssertThrowsError(
            try materialFill(in: sut),
            "under Reduce Transparency the material backdrop draws no material"
        )
    }

    func test_hudScene_materialBackdrop_drawsNoDim() throws {
        // The dim before the fade: black at no opacity.
        let dim = Color.black.opacity(0)

        XCTAssertNoThrow(
            try makeSUT(backdrop: nil).inspect().find(ViewType.Color.self, where: { try $0.value() == dim }),
            "the default backdrop draws the black dim, so the search does find a dim"
        )
        XCTAssertThrowsError(
            try makeSUT(backdrop: .material()).inspect().find(ViewType.Color.self, where: { try $0.value() == dim }),
            "the material backdrop draws its material and no dim"
        )
    }

    func test_hudScene_materialBackdrop_drawsTheMaterial() throws {
        XCTAssertNoThrow(
            try materialFill(in: makeSUT(backdrop: .material())),
            "the material backdrop fills the screen with its material"
        )
    }

    func test_hudScene_reduceTransparency_dimBackdrop_keepsItsColour() throws {
        let colour = Color.red.opacity(0.3)
        let sut = makeSUT(backdrop: .dim(colour)).environment(\.hudReducesTransparency, true)

        XCTAssertNoThrow(
            try sut.inspect().find(ViewType.Color.self, where: { try $0.value() == colour }),
            "under Reduce Transparency the dim backdrop keeps its colour"
        )
    }

    func test_hudScene_reduceTransparency_clearBackdrop_staysClear() throws {
        let sut = makeSUT(backdrop: .clear).environment(\.hudReducesTransparency, true)
        let dim = Color.black.opacity(0)

        XCTAssertNoThrow(try sut.inspect().find(text: "failed"), "the HUD of the clear backdrop is drawn")
        XCTAssertThrowsError(
            try sut.inspect().find(ViewType.Color.self, where: { try $0.value() == dim }),
            "under Reduce Transparency the clear backdrop still draws no dim"
        )
    }

    // MARK: - Helpers

    /// The shape that a material fills.
    private func materialFill(in view: some View) throws -> InspectableView<ViewType.Shape> {
        try view.inspect().find(ViewType.Shape.self, where: { (try? $0.fillShapeStyle(Material.self)) != nil })
    }

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
