//
//  File.swift
//  DMErrorHandling
//
//  Created by Nikolay Dementiev on 22.01.2025.
//

import SwiftUI

public extension View {
    func autoLoading<Provider: DMLoadingViewProvider>(_ loadingManager: DMLoadingManager<Provider>) -> some View {
        self
            .environmentObject(loadingManager)
            .modifier(DMLoadingModifier(loadingManager: loadingManager))
    }
    
}
