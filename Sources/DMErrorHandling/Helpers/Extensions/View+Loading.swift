//
//  File.swift
//  DMErrorHandling
//
//  Created by Nikolay Dementiev on 22.01.2025.
//

import SwiftUI

public extension View {
    func autoLoading(_ loadingManager: LoadingManager) -> some View {
        
        //reading the size from where the window is created:
        //WindowGroup {
//                GeometryReader { proxy in
//                    self
//                        .environment(\.mainWindowSize, proxy.size)
//                }
           // }
        
        return self
            .environmentObject(loadingManager)
            .modifier(
                LoadingModifier(loadingManager: loadingManager)
            )
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
