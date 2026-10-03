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
                    DMVariableBlurView(
                        maxBlurRadius: 4,
                        direction: .blurredCenterClearTopBottom(centerBandProportion: 0.4)
                    )

                    content()
                } else {
                    EmptyView()
                }
            }
        }
    }
}
