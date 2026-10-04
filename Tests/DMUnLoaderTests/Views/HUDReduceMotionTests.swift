//
//  DMUnLoader
//
//  Created by Mykola Dementiev
//

import SwiftUI
import ViewInspector
import XCTest
import DMUnLoader

/// Under Reduce Motion the HUD fades in without growing, and a pressed button changes its
/// colour without shrinking.
@MainActor
final class HUDReduceMotionTests: XCTestCase {

    func test_hud_reduceMotionEnabled_appearsWithoutScaleAnimation() throws {
        let scale = try cardScale(of: makeSUT())
        let reducedScale = try cardScale(of: makeSUT().environment(\.hudReducesMotion, true))

        XCTAssertEqual(scale, CGSize(width: 0.9, height: 0.9), "before it appears, the card is smaller and grows into place")
        XCTAssertEqual(
            reducedScale,
            CGSize(width: 1, height: 1),
            "under Reduce Motion the card has its full size before it appears"
        )
    }

    func test_hudButtonStyle_reduceMotion_pressedKeepsFullScale() throws {
        let pressed = try pressScale(isPressed: true, reducesMotion: false)
        let reducedPressed = try pressScale(isPressed: true, reducesMotion: true)
        let released = try pressScale(isPressed: false, reducesMotion: false)

        XCTAssertEqual(pressed, CGSize(width: 0.98, height: 0.98), "a pressed button shrinks a little")
        XCTAssertEqual(reducedPressed, CGSize(width: 1, height: 1), "under Reduce Motion a pressed button keeps its size")
        XCTAssertEqual(released, CGSize(width: 1, height: 1), "a released button has its full size")
    }

    func test_hudButtonStyle_scalesThePressedButtonThroughThePressScale() throws {
        let style = ActionButtonSettings(text: "Retry").styleFactory()

        let pressed = try pressScaleModifier(in: style.inspect(isPressed: true))
        let released = try pressScaleModifier(in: style.inspect(isPressed: false))

        XCTAssertTrue(pressed.isPressed, "the default button style hands a press to the press scale")
        XCTAssertFalse(released.isPressed, "the default button style hands a release to the press scale")
    }

    // MARK: - Helpers

    /// The HUD scene of a loading HUD, before it appears.
    private func makeSUT() -> DMHudSceneView<DMLoadingManagerMain> {
        let manager = DMLoadingManagerMain(
            state: .loading(provider: DefaultDMLoadingViewProvider().eraseToAnyViewProvider()),
            settings: DMLoadingManagerDefaultSettings(autoHideDelay: .seconds(600))
        )
        trackForMemoryLeaks(manager)
        return DMHudSceneView(loadingManager: manager)
    }

    /// The scale of the card: the only scale effect of the HUD scene.
    private func cardScale(of view: some View) throws -> CGSize {
        try view.inspect().find(where: { (try? $0.scaleEffect()) != nil }).scaleEffect()
    }

    private func pressScale(isPressed: Bool, reducesMotion: Bool) throws -> CGSize {
        try Text("Retry")
            .modifier(HUDPressScale(isPressed: isPressed))
            .environment(\.hudReducesMotion, reducesMotion)
            .inspect()
            .find(where: { (try? $0.scaleEffect()) != nil })
            .scaleEffect()
    }

    private func pressScaleModifier(in body: InspectableView<ViewType.ClassifiedView>) throws -> HUDPressScale {
        try body
            .find(where: { (try? $0.modifier(HUDPressScale.self)) != nil })
            .modifier(HUDPressScale.self)
            .actualView()
    }
}
