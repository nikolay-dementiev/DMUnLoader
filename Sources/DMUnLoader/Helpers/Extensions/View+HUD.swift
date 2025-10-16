//
//  DMUnLoader
//
//  Created by Mykola Dementiev
//

import SwiftUI
import DMVariableBlurView

extension View {
    func hudCenter<Content: View, LM: DMLoadingManagerProtocol>(
        loadingManager: LM,
        @ViewBuilder content: () -> Content
    ) -> some View {
        overlay(alignment: .center) {
            ZStack {
                switch loadingManager.loadableState {
                case .success,
                        .failure,
                        .loading:
                    DMVariableBlurView(
                        maxBlurRadius: 4,
                        direction: .blurredCenterClearTopBottom(centerBandProportion: 0.4)
                    )
                                        
                    content()
                case .none:
                    EmptyView()
                }
            }
        }
    }
}
