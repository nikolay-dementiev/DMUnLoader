//
//  LoadingView.swift
//  DMErrorHandling
//
//  Created by Nikolay Dementiev on 24.01.2025.
//

import SwiftUI

internal struct DMLoadingView<Provider: DMLoadingViewProvider>: View {
    
    @ObservedObject private(set) internal var loadingManager: DMLoadingManager<Provider>
    
    internal init(loadingManager: DMLoadingManager<Provider>) {
        self.loadingManager = loadingManager
    }
    
    internal var body: some View {
        ZStack {
            switch loadingManager.loadableState {
            case .none :
                EmptyView()
            default:
                ZStack {
                    Color.black.opacity(0.2)
                        .ignoresSafeArea()
                    
                    VStack(spacing: 20) {
                        switch loadingManager.loadableState {
                        case .loading:
                            loadingManager.provider.getLoadingView()
                        case .failure(let error, let onRetry):
                            loadingManager.provider.getErrorView(error: error,
                                                                 onRetry: onRetry,
                                                                 onClose: loadingManager.hide)
                        case .success(let object):
                            loadingManager.provider.getSuccessView(message: object)
                        case .none:
                            EmptyView()
                        }
                    }
                    .padding(30)
                    .background(Color.gray.opacity(0.8))
                    .cornerRadius(10)
                }
                .transition(.opacity)
                .animation(.easeInOut, value: loadingManager.loadableState)
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
    }
}

//#Preview {
//    LoadingView(loadingManager: LoadingManager(loadableState: .loading))
//}
