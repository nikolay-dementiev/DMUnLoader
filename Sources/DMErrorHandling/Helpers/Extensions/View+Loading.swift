//
//  File.swift
//  DMErrorHandling
//
//  Created by Nikolay Dementiev on 22.01.2025.
//

import SwiftUI

public extension View {
//    func autoLoading(_ loadingManager: LoadingManager) -> some View {
//        
//        return self
//            .environmentObject(loadingManager)
//            .modifier(
//                LoadingModifier(loadingManager: loadingManager)
//            )
//    }
    
    func autoLoading<Provider: LoadingViewProvider>(_ loadingManager: LoadingManager<Provider>) -> some View {
        self
            .environmentObject(loadingManager)
            .modifier(LoadingModifier(loadingManager: loadingManager))
    }
}


//private struct MainWindowSizeKey: EnvironmentKey {
//    static let defaultValue: CGSize = .zero
//}
//
//internal extension EnvironmentValues {
//    var mainWindowSize: CGSize {
//        get { self[MainWindowSizeKey.self] }
//        set { self[MainWindowSizeKey.self] = newValue }
//    }
//}
