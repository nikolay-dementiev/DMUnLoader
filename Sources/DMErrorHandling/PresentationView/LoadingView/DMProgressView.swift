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
    
    var loadingContainerForegroundColor: Color { get }
    
//    var deviceParameters: DeviceParameters { get }
}

//default implementation of settings
internal struct DMLoadingDefaultViewSettings: DMLoadingViewSettings {
    internal let loadingText: String
    internal let loadingTextAlignment: TextAlignment
    internal let loadingTextForegroundColor: Color
    internal let loadingTextFont: Font
    internal let loadingTextLineLimit: Int?
    internal let loadingTextLinePadding: EdgeInsets
    
    internal let progressIndicatorSize: ControlSize
    internal let progressIndicatorTintColor: Color?
    
    internal let loadingContainerForegroundColor: Color
    
//    internal var deviceParameters: DeviceParameters
    
    public init(loadingText: String = "Loading...",
                loadingTextAlignment: TextAlignment = .center,
                loadingTextForegroundColor: Color = .white,
                loadingTextFont: Font = .body,
                loadingTextLineLimit: Int? = 3,
                loadingTextLinePadding: EdgeInsets? = nil, //can't use extension's init due to it's has `internal` access lewel
                progressIndicatorSize: ControlSize = .large,
                progressIndicatorTintColor: Color? = .white,
                loadingContainerForegroundColor: Color = Color.primary
                //,
//                deviceParameters: DeviceParameters = DMDeviceParameters()
    ) {
        
        self.loadingText = loadingText
        self.loadingTextAlignment = loadingTextAlignment
        self.loadingTextForegroundColor = loadingTextForegroundColor
        self.loadingTextFont = loadingTextFont
        self.loadingTextLineLimit = loadingTextLineLimit
        self.loadingTextLinePadding = loadingTextLinePadding ?? EdgeInsets(left: 10,
                                                                           right: 10)
        
        self.progressIndicatorSize = progressIndicatorSize
        self.progressIndicatorTintColor = progressIndicatorTintColor
        
        self.loadingContainerForegroundColor = loadingContainerForegroundColor
        
//        self.deviceParameters = deviceParameters
    }
}

internal struct DMProgressView: View {
    
    internal let settingsProvider: DMLoadingViewSettings
    
    /// provides an initializer for instance.
    /// - Parameter settingsProvider: the settings used to set this view.
    /// In case this parameter is not provided - it will be used as default settings by calling
    /// `Self.getSettingsProvider()` by `LoadingViewScene` protocol responsibility
    internal init(settings settingsProvider: DMLoadingViewSettings) {
        self.settingsProvider = settingsProvider
    }
    
    internal var body: some View {
        //let geometry = type(of: settingsProvider.deviceParameters).deviceScreenSize
        
        //TODO: Need to provide correct devise SIZE
        let geometry = CGSize(width: 300, height: 300)
        
        ZStack(alignment: .center) {
            
            let minSize = min(geometry.width - 20,
                              geometry.height - 20,
                              30)
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
                    .layoutPriority(1)
            }
            .frame(minWidth: minSize,
                   maxWidth: geometry.width / 2,
                   minHeight: minSize,
                   maxHeight: geometry.height / 2)
            .fixedSize()
            .foregroundColor(settingsProvider.loadingContainerForegroundColor)
//            .debugLog("VStack")
        }
        //.debugLog("ZStack")
    }
}
//
//#Preview {
//    DMNativeProgressView(settingsProvider: DMLoadingDefaultViewSettings(loadingText: "Some very long loading text here; and even more than that text is the reason for that..."))
//}
//
//#Preview {
//    DMNativeProgressView(settingsProvider: DMLoadingDefaultViewSettings(loadingText: "Loading"))
//}

