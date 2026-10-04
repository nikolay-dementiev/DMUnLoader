//
//  DMUnLoader
//
//  Created by Mykola Dementiev
//

import SwiftUI
import XCTest
import DMUnLoader

/// What each backdrop draws, by kind and by Reduce Transparency, decided without rendering: the
/// layer behind the card and the dim that fades in with it.
final class HUDBackdropDrawingTests: XCTestCase {

    func test_variableBlur_drawsTheBlurAndTheStandardDim_underReduceTransparencyTheDimOnly() {
        let drawn = DMHUDBackdrop.variableBlur.drawing(reducesTransparency: false)
        let reduced = DMHUDBackdrop.variableBlur.drawing(reducesTransparency: true)

        XCTAssertTrue(isVariableBlur(drawn.layer), "the variable blur lies behind the card")
        XCTAssertEqual(drawn.dim, .standard, "under the black dim of the default backdrop")
        XCTAssertTrue(isNone(reduced.layer), "under Reduce Transparency no blur is drawn")
        XCTAssertEqual(reduced.dim, .standard, "under Reduce Transparency the dim stays")
    }

    func test_material_drawsTheMaterialAndNoDim_underReduceTransparencyTheStandardDim() {
        let drawn = DMHUDBackdrop.material(.thinMaterial).drawing(reducesTransparency: false)
        let reduced = DMHUDBackdrop.material(.thinMaterial).drawing(reducesTransparency: true)

        XCTAssertTrue(isMaterial(drawn.layer), "the material lies behind the card")
        XCTAssertEqual(drawn.dim, .none, "a material draws no dim")
        XCTAssertTrue(isNone(reduced.layer), "under Reduce Transparency no material is drawn")
        XCTAssertEqual(reduced.dim, .standard, "under Reduce Transparency the dim of the default backdrop takes its place")
    }

    func test_dim_drawsItsColour_withAndWithoutReduceTransparency() {
        let colour = Color.red.opacity(0.3)

        for reducesTransparency in [false, true] {
            let drawn = DMHUDBackdrop.dim(colour).drawing(reducesTransparency: reducesTransparency)
            XCTAssertTrue(isNone(drawn.layer), "a dim has nothing behind it (Reduce Transparency \(reducesTransparency))")
            XCTAssertEqual(drawn.dim, .color(colour), "a dim draws its colour (Reduce Transparency \(reducesTransparency))")
        }
    }

    func test_clear_drawsNothing_withAndWithoutReduceTransparency() {
        for reducesTransparency in [false, true] {
            let drawn = DMHUDBackdrop.clear.drawing(reducesTransparency: reducesTransparency)
            XCTAssertTrue(isNone(drawn.layer), "the clear backdrop draws no layer (Reduce Transparency \(reducesTransparency))")
            XCTAssertEqual(drawn.dim, .none, "the clear backdrop draws no dim (Reduce Transparency \(reducesTransparency))")
        }
    }

    // MARK: - Helpers

    private func isVariableBlur(_ layer: HUDBackdropDrawing.Layer) -> Bool {
        if case .variableBlur = layer {
            return true
        }
        return false
    }

    /// `Material` is not comparable, so a material layer is recognised by its case alone.
    private func isMaterial(_ layer: HUDBackdropDrawing.Layer) -> Bool {
        if case .material = layer {
            return true
        }
        return false
    }

    private func isNone(_ layer: HUDBackdropDrawing.Layer) -> Bool {
        if case .none = layer {
            return true
        }
        return false
    }
}
