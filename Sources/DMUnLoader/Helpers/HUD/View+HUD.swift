//
//  DMUnLoader
//
//  Created by Mykola Dementiev
//

import SwiftUI

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
                    VariableBlurView(maxBlurRadius: 8)
                                        
                    content()
                case .none:
                    EmptyView()
                }
            }
        }
    }
}
