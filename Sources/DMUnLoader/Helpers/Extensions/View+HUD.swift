//
//  DMUnLoader
//
//  Created by Mykola Dementiev
//

import SwiftUI
import DMVariableBlurView

extension View {
    func hudCenter<Content: View, LM: DMLoadingManager>(
        loadingManager: LM,
        backdropLayer: HUDBackdropDrawing.Layer,
        blur: HUDBlurValues = .hud,
        @ViewBuilder content: () -> Content
    ) -> some View {
        overlay(alignment: .center) {
            ZStack {
                if loadingManager.loadableState.showsHUD {
                    HUDBackdropLayer(layer: backdropLayer, blur: blur)

                    content()
                } else {
                    EmptyView()
                }
            }
        }
    }
}

/// The values of the variable blur of the HUD. A test gives the blur other values, a negative
/// radius for one, so that the blur fails for real.
package struct HUDBlurValues: Sendable {
    package let maxBlurRadius: CGFloat
    package let centerBandProportion: CGFloat

    package init(maxBlurRadius: CGFloat, centerBandProportion: CGFloat) {
        self.maxBlurRadius = maxBlurRadius
        self.centerBandProportion = centerBandProportion
    }

    /// The values of the HUD: a radius of at most 4 points, strongest in a band across 40 percent of the height.
    package static let hud = HUDBlurValues(maxBlurRadius: 4, centerBandProportion: 0.4)
}

/// What the backdrop draws under the HUD's dim: the variable blur, a material, or nothing.
struct HUDBackdropLayer: View {
    let layer: HUDBackdropDrawing.Layer
    let blur: HUDBlurValues

    var body: some View {
        switch layer {
        case .variableBlur:
            DMVariableBlurView(
                maxBlurRadius: blur.maxBlurRadius,
                direction: .blurredCenterClearTopBottom(centerBandProportion: blur.centerBandProportion)
            )
        case let .material(material):
            Rectangle()
                .fill(material)
                .ignoresSafeArea()
        case .none:
            EmptyView()
        }
    }
}
