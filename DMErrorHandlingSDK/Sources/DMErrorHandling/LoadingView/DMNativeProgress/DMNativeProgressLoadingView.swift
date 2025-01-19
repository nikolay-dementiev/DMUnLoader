//
//  DMNativeProgressView.swift
//  DMErrorHandling
//
//  Created by Nikolay Dementiev on 19.01.2025.
//
//take a look for details: https://stackoverflow.com/a/56496896/6643923

import SwiftUI

// This protocol restponsible to provide settings for ProgressView
public protocol DMLoadingViewSettings {
    var loadingText: String { get }
    var progressIndicatorSize: ControlSize { get }
    var loadingContainerBackgroundView: AnyView { get }
    var loadingContainerForegroundColor: Color { get }
    var loadingContainerCornerRadius: CGFloat { get }
    var loadingContainerCornerOpacity: Double { get }
}

//default implementation of settings - so any of those bacame not mandatory
public extension DMLoadingViewSettings {
    var loadingText: String { "Loading..." }
    var progressIndicatorSize: ControlSize { .large }
    var loadingContainerBackgroundView: AnyView { AnyView(Color.secondary.colorInvert()) }
    var loadingContainerForegroundColor: Color { Color.primary }
    var loadingContainerCornerRadius: CGFloat { 20 }
    var loadingContainerCornerOpacity: Double { 1 }
}

internal struct DMLoadingDefaultViewSettings: DMLoadingViewSettings {
    
}

internal struct DMNativeProgressView: View, LoadingViewScene {
    
    internal let settingsProvider: DMLoadingViewSettings
    
    /// provides an initializer for instance.
    /// - Parameter settingsProvider: the settings used to set this view.
    /// In case this parameter is not provided - it will be used as default settings by calling `Self.getSettingsProvider()` ->
    /// by `LoadingViewScene` protocol responsibility
    internal init(settingsProvider: DMLoadingViewSettings = Self.getSettingsProvider()) {
        self.settingsProvider = settingsProvider
    }
    
    internal var body: some View {
        GeometryReader { geometry in
            ZStack(alignment: .center) {
                
                VStack {
                    Text(settingsProvider.loadingText)
                    ProgressView()
                        .controlSize(settingsProvider.progressIndicatorSize)
                        .progressViewStyle(CircularProgressViewStyle())
                }
                .frame(width: geometry.size.width / 3,
                       height: geometry.size.height / 7)
                .background(settingsProvider.loadingContainerBackgroundView)
                .foregroundColor(settingsProvider.loadingContainerForegroundColor)
                .cornerRadius(settingsProvider.loadingContainerCornerRadius)
                .opacity(settingsProvider.loadingContainerCornerOpacity)
                
            }
            .frame(maxWidth: .infinity,
                   maxHeight: .infinity)
        }
    }
}

#Preview {
    DMNativeProgressView()
}

