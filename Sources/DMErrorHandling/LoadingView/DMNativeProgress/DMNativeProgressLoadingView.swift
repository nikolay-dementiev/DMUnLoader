//
//  DMNativeProgressView.swift
//  DMErrorHandling
//
//  Created by Nikolay Dementiev on 19.01.2025.
//
// take a look for details: https://stackoverflow.com/a/56496896/6643923

import SwiftUI

// This protocol restponsible to provide settings for ProgressView
public protocol DMLoadingViewSettings {
    var loadingText: String { get }
    var loadingTextAlignment: TextAlignment { get }
    var loadingTextForegroundColor: Color { get }
    var loadingTextLineLimit: Int? { get }
    var loadingTextFont: Font { get }
    var loadingTextLinePadding: EdgeInsets { get }
    
    var progressIndicatorSize: ControlSize { get }
    var progressIndicatorTintColor: Color? { get }
    
    var loadingContainerBackgroundView: AnyView { get }
    var loadingContainerForegroundColor: Color { get }
    var loadingContainerCornerRadius: CGFloat { get }
    var loadingContainerCornerOpacity: Double { get }
}

//default implementation of settings
public struct DMLoadingDefaultViewSettings: DMLoadingViewSettings {
    public let loadingText: String
    public let loadingTextAlignment: TextAlignment
    public let loadingTextForegroundColor: Color
    public let loadingTextFont: Font
    public let loadingTextLineLimit: Int?
    public let loadingTextLinePadding: EdgeInsets
    
    public let progressIndicatorSize: ControlSize
    public let progressIndicatorTintColor: Color?
    
    public let loadingContainerBackgroundView: AnyView
    public let loadingContainerForegroundColor: Color
    public let loadingContainerCornerRadius: CGFloat
    public let loadingContainerCornerOpacity: Double
    
    public init(loadingText: String = "Loading...",
                loadingTextAlignment: TextAlignment = .center,
                loadingTextForegroundColor: Color = .black,
                loadingTextFont: Font = .body,
                loadingTextLineLimit: Int? = 3,
                loadingTextLinePadding: EdgeInsets? = nil, //can't use extension's init due to it's has `internal` access lewel
                progressIndicatorSize: ControlSize = .large,
                progressIndicatorTintColor: Color? = nil,
                loadingContainerBackgroundView: AnyView = AnyView(Color.secondary.colorInvert()),
                loadingContainerForegroundColor: Color = Color.primary,
                loadingContainerCornerRadius: CGFloat = 20,
                loadingContainerCornerOpacity: Double = 1) {
        
        self.loadingText = loadingText
        self.loadingTextAlignment = loadingTextAlignment
        self.loadingTextForegroundColor = loadingTextForegroundColor
        self.loadingTextFont = loadingTextFont
        self.loadingTextLineLimit = loadingTextLineLimit
        self.loadingTextLinePadding = loadingTextLinePadding ?? EdgeInsets(left: 10,
                                                                           right: 10)
        
        self.progressIndicatorSize = progressIndicatorSize
        self.progressIndicatorTintColor = progressIndicatorTintColor
        
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
                        .foregroundColor(settingsProvider.loadingTextForegroundColor)
                        .font(settingsProvider.loadingTextFont)
                        .lineLimit(settingsProvider.loadingTextLineLimit)
                        .padding(settingsProvider.loadingTextLinePadding)
                    ProgressView()
                        .controlSize(settingsProvider.progressIndicatorSize)
                        .progressViewStyle(.circular) // .linear
                        .tint(settingsProvider.progressIndicatorTintColor)
                }
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
    DMNativeProgressView(settingsProvider: DMLoadingDefaultViewSettings(loadingText: "Some very long loading text here; and even more than that text is the reason for that..."))
}

#Preview {
    DMNativeProgressView(settingsProvider: DMLoadingDefaultViewSettings(loadingText: "Loading"))
}

