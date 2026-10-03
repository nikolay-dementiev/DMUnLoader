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
        @ViewBuilder content: () -> Content
    ) -> some View {
        overlay(alignment: .center) {
            ZStack {
                if loadingManager.loadableState.showsHUD {
                    HUDBackdropLayer(backdrop: loadingManager.settings.backdrop)

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
    let backdrop: DMHUDBackdrop

    var body: some View {
        switch backdrop.kind {
        case .variableBlur:
            DMVariableBlurView(
                maxBlurRadius: 4,
                direction: .blurredCenterClearTopBottom(centerBandProportion: 0.4)
            )
        case let .material(material):
            Rectangle()
                .fill(material)
                .ignoresSafeArea()
        case .dim, .clear:
            EmptyView()
        }
    }
}
