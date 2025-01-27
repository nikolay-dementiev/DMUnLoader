//
//  LoadingViewScene.swift
//  DMErrorHandling
//
//  Created by Nikolay Dementiev on 16.01.2025.
//

import SwiftUI

///This protocol provide various loadingView that can uses for LoadingView
///check for detail: https://stackoverflow.com/a/65585090/6643923

public protocol LoadingViewScene {
    static func getSettingsProvider() -> DMLoadingViewSettings
    
    //TODO: Get rid of `AnyView` -> wrap it somehow
    func getLoadingView() -> AnyView
    
//    @MainActor
//    init(settingsProvider: DMLoadingViewSettings)
}

///This extension provide default implementation of `View` as loading indicatior by itself
internal extension LoadingViewScene where Self: View {
    func getLoadingView() -> AnyView {
        AnyView(self)
    }
    
//    @MainActor @ViewBuilder
//    static func `init`() -> some View {
//        Self.init(settingsProvider: getSettingsProvider())
//    }
}

internal extension LoadingViewScene {
    static func getSettingsProvider() -> DMLoadingViewSettings {
        DMLoadingDefaultViewSettings()
    }
}
