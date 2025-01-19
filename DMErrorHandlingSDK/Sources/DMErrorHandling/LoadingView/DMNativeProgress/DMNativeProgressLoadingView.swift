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

//default implementation of settings
public struct DMLoadingDefaultViewSettings: DMLoadingViewSettings {
    public let loadingText: String
    public let progressIndicatorSize: ControlSize
    public let loadingContainerBackgroundView: AnyView
    public let loadingContainerForegroundColor: Color
    public let loadingContainerCornerRadius: CGFloat
    public let loadingContainerCornerOpacity: Double
    
    public init(loadingText: String = "Loading...",
                progressIndicatorSize: ControlSize = .large,
                loadingContainerBackgroundView: AnyView = AnyView(Color.secondary.colorInvert()),
                loadingContainerForegroundColor: Color = Color.primary,
                loadingContainerCornerRadius: CGFloat = 20,
                loadingContainerCornerOpacity: Double = 1) {
        
        self.loadingText = loadingText
        self.progressIndicatorSize = progressIndicatorSize
        self.loadingContainerBackgroundView = loadingContainerBackgroundView
        self.loadingContainerForegroundColor = loadingContainerForegroundColor
        self.loadingContainerCornerRadius = loadingContainerCornerRadius
        self.loadingContainerCornerOpacity = loadingContainerCornerOpacity
    }
}

internal struct DMNativeProgressView: View, LoadingViewScene {
    
    internal let settingsProvider: DMLoadingViewSettings
    
    /// provides an initializer for instance.
    /// - Parameter settingsProvider: the settings used to set this view.
    /// In case this parameter is not provided - it will be used as default settings by calling
    /// `Self.getSettingsProvider()` by `LoadingViewScene` protocol responsibility
    internal init(settingsProvider: DMLoadingViewSettings = Self.getSettingsProvider()) {
        self.settingsProvider = settingsProvider
    }
    
    internal var body: some View {
        GeometryReader { geometry in
            ZStack(alignment: .center) {
                
                VStack {
                    Text(settingsProvider.loadingText)
                        .multilineTextAlignment(.center)
                        .lineLimit(3)
                    ProgressView()
                        .controlSize(settingsProvider.progressIndicatorSize)
                        .progressViewStyle(CircularProgressViewStyle())
                }
                .padding(EdgeInsets(left: 10, right: 10))
                .frame(minWidth: geometry.size.width / 3,
                       maxWidth: geometry.size.width / 2,
                       minHeight: geometry.size.height / 7,
                       maxHeight: geometry.size.height / 5
                )
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
    DMNativeProgressView(settingsProvider: DMLoadingDefaultViewSettings(loadingText: "Loading adasd asasd asdas asd asd das asadsa as as asd assd asd..."))
}

#Preview {
    DMNativeProgressView(settingsProvider: DMLoadingDefaultViewSettings(loadingText: "Loading"))
}

