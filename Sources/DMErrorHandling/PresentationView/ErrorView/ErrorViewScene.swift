//
//  File.swift
//  DMErrorHandling
//
//  Created by Nikolay Dementiev on 25.01.2025.
//

import SwiftUI

///This protocol provide various loadingView that can uses for LoadingView
///check for detail: https://stackoverflow.com/a/65585090/6643923

//protocol SomeViewScene {
//    associatedtype SettingsType
//    
//    static func getSettingsProvider() -> SettingsType
//    func getErrorView() -> AnyView
//}


public protocol ErrorViewScene {
    static func getSettingsProvider() -> DMErrorViewSettings
    
    //TODO: Get rid of `AnyView` -> wrap it somehow
    func getErrorView() -> AnyView
}

///This extension provide default implementation of `View` as loading indicatior by itself
internal extension ErrorViewScene where Self: View {
    func getErrorView() -> AnyView {
        AnyView(self)
    }
}

internal extension ErrorViewScene {
    static func getSettingsProvider() -> DMErrorViewSettings {
        DMErrorDefaultViewSettings()
    }
}
