//
//  LoadingView.swift
//  DMErrorHandling
//
//  Created by Nikolay Dementiev on 24.01.2025.
//

import SwiftUI

public struct LoadingView: View {
    
    @ObservedObject private(set) internal var loadingManager: LoadingManager
    
    public let loadingViewScene: LoadingViewScene = DMNativeProgressView()
    
    internal init(loadingManager: LoadingManager) {
        self.loadingManager = loadingManager
    }
    
    public var body: some View {
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
