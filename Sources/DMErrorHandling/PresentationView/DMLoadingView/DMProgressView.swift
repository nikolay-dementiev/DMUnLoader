//
//  DMNativeProgressView.swift
//  DMErrorHandling
//
//  Created by Nikolay Dementiev on 19.01.2025.
//
// take a look for details: https://stackoverflow.com/a/56496896/6643923

import SwiftUI

internal struct DMProgressView: View {
    
    internal let settingsProvider: DMLoadingViewSettings
    
    internal init(settings settingsProvider: DMLoadingViewSettings) {
        self.settingsProvider = settingsProvider
    }
    
    internal var body: some View {
        let geometry = settingsProvider.frameGeometrySize
        let loadingTextProperties = settingsProvider.loadingTextProperties
        let progressIndicatorProperties = settingsProvider.progressIndicatorProperties
        
        ZStack(alignment: .center) {
            
            let minSize = min(geometry.width - 20,
                              geometry.height - 20,
                              30)
            VStack {
                Text(loadingTextProperties.text)
                    .multilineTextAlignment(.center)
                    .foregroundColor(loadingTextProperties.foregroundColor)
                    .font(loadingTextProperties.font)
                    .lineLimit(loadingTextProperties.lineLimit)
                    .padding(loadingTextProperties.linePadding)
                ProgressView()
                    .controlSize(progressIndicatorProperties.size)
                    .progressViewStyle(.circular) // .linear
                    .tint(progressIndicatorProperties.tintColor)
                    .layoutPriority(1)
            }
            .frame(minWidth: minSize,
                   maxWidth: geometry.width / 2,
                   minHeight: minSize,
                   maxHeight: geometry.height / 2)
            .fixedSize()
            .foregroundColor(settingsProvider.loadingContainerForegroundColor)
            //.debugLog("VStack")
        }
        //.debugLog("ZStack")
    }
}

//#Preview {
//    DMNativeProgressView(settingsProvider: DMLoadingDefaultViewSettings(loadingText: "Some very long loading text here; and even more than that text is the reason for that..."))
//}
//
//#Preview {
//    DMNativeProgressView(settingsProvider: DMLoadingDefaultViewSettings(loadingText: "Loading"))
//}

