//
//  DMErrorHandling
//
//  Created by Mykola Dementiev
//

import SwiftUI

internal enum DMLoadingViewOwnSettings {
    static let emptyViewTag: Int = 0001
    static let defaultViewTag: Int = 0102
    static let loadingViewTag: Int = 0203
    static let failureViewTag: Int = 0304
    static let successViewTag: Int = 0405
    static let noneViewTag: Int = 1001
    static let tapGestureViewTag: Int = 0515
}

internal struct DMLoadingView<Provider: DMLoadingViewProviderProtocol,
                              LLM: DMLoadingManagerInteralProtocol>: View {
    
    @ObservedObject private(set) internal var loadingManager: LLM
    internal var provider: Provider
    
    internal init(loadingManager: LLM,
                  provider: Provider) {
        self.loadingManager = loadingManager
        self.provider = provider
    }
    
    internal var body: some View {
        ZStack {
            switch loadingManager.loadableState {
            case .none:
                EmptyView()
                    .tag(DMLoadingViewOwnSettings.emptyViewTag)
            default:
                ZStack {
                    Color.black.opacity(0.2)
                        .ignoresSafeArea()
                    
                    VStack(spacing: 20) {
                        switch loadingManager.loadableState {
                        case .loading:
                            provider.getLoadingView()
                                .tag(DMLoadingViewOwnSettings.loadingViewTag)
                        case .failure(let error, let onRetry):
                            provider.getErrorView(error: error,
                                                  onRetry: onRetry,
                                                  onClose: DMButtonAction(loadingManager.hide))
                            .tag(DMLoadingViewOwnSettings.failureViewTag)
                        case .success(let object):
                            provider.getSuccessView(object: object)
                                .tag(DMLoadingViewOwnSettings.successViewTag)
                        case .none:
                            // It's a rudiment. Never be executed. Check the line above
                            EmptyView()
                                .tag(DMLoadingViewOwnSettings.noneViewTag)
                        }
                    }
                    .padding(30)
                    .background(Color.gray.opacity(0.8))
                    .cornerRadius(10)
                }
                .transition(.opacity)
                .animation(.easeInOut, value: loadingManager.loadableState)
                .tag(DMLoadingViewOwnSettings.defaultViewTag)
            }
        }.onTapGesture {
            switch loadingManager.loadableState {
            case .success,
                    .failure,
                    .none:
                loadingManager.hide()
            case .loading:
                break
            }
        }
        .tag(DMLoadingViewOwnSettings.tapGestureViewTag)
    }
}
