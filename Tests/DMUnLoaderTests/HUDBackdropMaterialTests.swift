//
//  DMUnLoader
//
//  Created by Mykola Dementiev
//

import SwiftUI
import ViewInspector
import XCTest
import DMUnLoader

/// Which material the HUD fills the screen with. A `Material` cannot be compared with `==`, and a
/// rendering of it in a test target draws nothing of it, so the material that the HUD fills with is
/// read from the view it draws and compared by its description, which names the material.
@MainActor
final class HUDBackdropMaterialTests: XCTestCase {

    func test_hudScene_materialBackdrop_fillsWithTheMaterialOfTheSettings() throws {
        let thin = Material.thinMaterial
        let thick = Material.ultraThickMaterial
        XCTAssertNotEqual(
            describing(thin),
            describing(thick),
            "the comparison below can tell two materials apart, or it would pass for any material"
        )

        let filledForThin = try materialFilled(by: makeSUT(material: thin))
        let filledForThick = try materialFilled(by: makeSUT(material: thick))

        XCTAssertEqual(
            describing(filledForThin),
            describing(thin),
            "the HUD fills with the thin material that the settings name"
        )
        XCTAssertEqual(
            describing(filledForThick),
            describing(thick),
            "the HUD fills with the ultra thick material that the settings name"
        )
    }

    // MARK: - Helpers

    private func describing(_ material: Material) -> String {
        String(describing: material)
    }

    /// The material that the one shape of the view filled with a material is filled with.
    private func materialFilled(by view: some View) throws -> Material {
        try view.inspect()
            .find(ViewType.Shape.self, where: { (try? $0.fillShapeStyle(Material.self)) != nil })
            .fillShapeStyle(Material.self)
    }

    /// The HUD scene of a failure, with a material backdrop of the given material.
    private func makeSUT(material: Material) -> DMHudSceneView<DMLoadingManagerMain> {
        let settings = DMLoadingManagerDefaultSettings(autoHideDelay: .seconds(600), backdrop: .material(material))
        let provider = DefaultDMLoadingViewProvider().eraseToAnyViewProvider()
        let manager = DMLoadingManagerMain(
            state: .failure(error: DMAppError.custom("failed"), provider: provider),
            settings: settings
        )
        trackForMemoryLeaks(manager)
        return DMHudSceneView(loadingManager: manager)
    }
}
