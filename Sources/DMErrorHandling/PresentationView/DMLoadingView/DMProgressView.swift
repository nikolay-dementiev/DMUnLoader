//
//  DMErrorHandling
//
//  Created by Mykola Dementiev
//
// take a look for details: https://stackoverflow.com/a/56496896/6643923

import SwiftUI

internal enum DMProgressViewOwnSettings {
    static let containerViewTag: Int = 2102
    static let progressViewTag: Int = 2203
    static let textTag: Int = 2204
    static let vStackViewTag = 2205
}

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
                    .tag(DMProgressViewOwnSettings.textTag)
                ProgressView()
                    .controlSize(progressIndicatorProperties.size)
                    .progressViewStyle(.circular) // .linear
                    .tint(progressIndicatorProperties.tintColor)
                    .layoutPriority(1)
                    .tag(DMProgressViewOwnSettings.progressViewTag)
            }
            .frame(minWidth: minSize,
                   maxWidth: geometry.width / 2,
                   minHeight: minSize,
                   maxHeight: geometry.height / 2)
            .fixedSize()
            .foregroundColor(settingsProvider.loadingContainerForegroundColor)
            .tag(DMProgressViewOwnSettings.vStackViewTag)
        }
        .tag(DMProgressViewOwnSettings.containerViewTag)
    }
}
