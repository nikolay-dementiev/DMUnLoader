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
        @ViewBuilder content: () -> Content
    ) -> some View {
        overlay(alignment: .center) {
            ZStack {
                if loadingManager.loadableState.showsHUD {
                    HUDBackdropLayer(layer: backdropLayer)

                    content()
                } else {
                    EmptyView()
                }
            }
        }
    }
}

/// What the backdrop draws under the HUD's dim: the variable blur, a material, or nothing.
struct HUDBackdropLayer: View {
    let layer: HUDBackdropDrawing.Layer

    var body: some View {
        switch layer {
        case .variableBlur:
            DMVariableBlurView(
                maxBlurRadius: 4,
                direction: .blurredCenterClearTopBottom(centerBandProportion: 0.4)
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
