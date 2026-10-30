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
        blur: HUDBlurValues,
        onBackdropFailure: (@MainActor @Sendable (DMHUDBackdropFailure) -> Void)?,
        @ViewBuilder content: () -> Content
    ) -> some View {
        overlay(alignment: .center) {
            ZStack {
                if loadingManager.loadableState.showsHUD {
                    HUDBackdropLayer(layer: backdropLayer, blur: blur, onFailure: onBackdropFailure)

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
    /// Told when the variable blur could not be drawn. `nil` leaves the blur view without a handler,
    /// so that it keeps writing its failure to the log.
    let onFailure: (@MainActor @Sendable (DMHUDBackdropFailure) -> Void)?

    var body: some View {
        switch layer {
        case .variableBlur:
            variableBlur
        case let .material(material):
            Rectangle()
                .fill(material)
                .ignoresSafeArea()
        case .none:
            EmptyView()
        }
    }

    /// On the main actor like `body`: the Swift 5 mode of the pod isolates only `body`, and reads the
    /// handler in here as a function value that is not `Sendable`.
    @MainActor
    private var variableBlur: DMVariableBlurView {
        let view = DMVariableBlurView(
            maxBlurRadius: blur.maxBlurRadius,
            direction: .blurredCenterClearTopBottom(centerBandProportion: blur.centerBandProportion)
        )
        guard let handler = HUDBackdropFailureForwarder.leafHandler(for: onFailure) else {
            return view
        }
        return view.onFailure(handler)
    }
}
