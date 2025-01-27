//
//  LoadingView.swift
//  DMErrorHandling
//
//  Created by Nikolay Dementiev on 24.01.2025.
//

import SwiftUI

internal struct LoadingView: View {
    
    @ObservedObject private(set) internal var loadingManager: LoadingManager
    
    //TODO: need to push it to client's classes - so the cliet's App cant use it's
    //own classes and provide correct data
    private(set) internal var loadingViewScene: LoadingViewScene = DMNativeProgressView()
    private(set) internal var errorViewScene: ((Error, (() -> Void)?) -> ErrorViewScene)? = nil
    
    
    
    
    internal init(loadingManager: LoadingManager) {
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
                            /*
                             ProgressView()
                                .progressViewStyle(CircularProgressViewStyle(tint: .white))
                            Text("Завантаження...")
                                .font(.headline)
                                .foregroundColor(.white)
                            
                            */
                            
                            loadingViewScene.getLoadingView()
                        case .failure(let error, let onRetry):
                            /*
                            VStack {
                                Image(systemName: "exclamationmark.triangle")
                                    .resizable()
                                    .frame(width: 50, height: 50)
                                    .foregroundColor(.red)
                                Text(error.localizedDescription)
                                    .foregroundColor(.white)
                                    .multilineTextAlignment(.center)
                                if let onRetry = onRetry {
                                    Button("Повторити") {
                                        onRetry()
                                    }
                                    .padding()
                                    .background(Color.white)
                                    .cornerRadius(8)
                                }
                            }
                            */
                            
//
//                            errorViewScene = {
//                                ErrorView(error: $0, onRetry: $1)
//                            }(error, onRetry)
//    
//                            errorViewScene.getErrorView()
                            ErrorView(error: error, onRetry: onRetry)
                        case .success(let message):
                            VStack {
                                Image(systemName: "checkmark.circle.fill")
                                    .resizable()
                                    .frame(width: 50, height: 50)
                                    .foregroundColor(.green)
                                Text("\(message as? String ?? "Успішно!")")
                                    .foregroundColor(.white)
                            }
                            
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
            case .success, .failure, .none:
                loadingManager.hide()
            case .loading:
                break
            }
        }
    }
}
//
//#Preview {
//    LoadingView(loadingManager: LoadingManager(loadableState: .loading))
//}
