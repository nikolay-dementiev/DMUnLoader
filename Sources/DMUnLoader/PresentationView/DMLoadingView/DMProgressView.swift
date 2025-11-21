//
//  DMUnLoader
//
//  Created by Mykola Dementiev
//
// take a look for details: https://stackoverflow.com/a/56496896/6643923

import SwiftUI

/// A namespace for constants used in the `DMProgressView`.
/// These constants define unique tags for views within the progress view.
enum DMProgressViewOwnSettings {
    
    /// The tag assigned to the container view that holds all content in the progress view.
    static let containerViewTag: Int = 2102
    
    /// The tag assigned to the progress indicator view displayed in the progress view.
    static let progressViewTag: Int = 2203
    
    /// The tag assigned to the text view displayed in the progress view.
    static let textTag: Int = 2204
    
    /// The tag assigned to the vertical stack view (`VStack`) that organizes the content.
    static let vStackViewTag: Int = 2205
    
    /// The tag assigned to the ztack view (`ZStack`) that organizes the content.
    static let zStackViewTag: Int = 2206
    
    /// The tag assigned to the container color
    static let containerbackgroundColorViewTag: Int = 2107
}

/// A custom SwiftUI view that displays a progress indicator with optional text.
/// This view uses a settings provider to configure the appearance of the progress view.
struct DMProgressView: View {
    let settingsProvider: DMProgressViewSettings
    
    init(settings settingsProvider: DMProgressViewSettings) {
        self.settingsProvider = settingsProvider
    }
    
    var body: some View {
        let geometry = settingsProvider.frameGeometrySize
        let loadingTextProperties = settingsProvider.loadingTextProperties
        let progressIndicatorProperties = settingsProvider.progressIndicatorProperties
        
        let minSize: CGFloat = 30
        ZStack(alignment: .center) {
            Color(settingsProvider.loadingContainerBackgroundColor)
                .tag(DMProgressViewOwnSettings.containerbackgroundColorViewTag)
            VStack {
                Text(loadingTextProperties.text)
                    .foregroundColor(loadingTextProperties.foregroundColor)
                    .font(loadingTextProperties.font)
                    .lineLimit(loadingTextProperties.lineLimit)
                    .padding(loadingTextProperties.linePadding)
                    .tag(DMProgressViewOwnSettings.textTag)
                
                ProgressView()
                    .controlSize(progressIndicatorProperties.size)
                    .progressViewStyle(progressIndicatorProperties.style)
                    .tint(progressIndicatorProperties.tintColor)
                    .layoutPriority(1)
                    .tag(DMProgressViewOwnSettings.progressViewTag)
            }
        }
        .frame(minWidth: minSize,
               maxWidth: geometry.width / 2,
               minHeight: minSize,
               maxHeight: geometry.height / 2)
        .fixedSize()
        .tag(DMProgressViewOwnSettings.zStackViewTag)
    }
}

#Preview("DefaultSettings") {
    PreviewRenderOwner {
        DMProgressView(settings: DMProgressViewDefaultSettings())
    }
}

#Preview("CustomSettings") {
    PreviewRenderOwner {
        DMProgressView(settings: DMProgressViewDefaultSettings(
            loadingTextProperties: .init(
                text: "Loading super long text...",
                foregroundColor: .white,
                font: .headline,
                lineLimit: 2,
                linePadding: .init(top: 5, leading: 10, bottom: 5, trailing: 10)
            ),
            progressIndicatorProperties: .init(
                size: .large,
                tintColor: .yellow
            ),
            frameGeometrySize: .init(width: 200, height: 200)
        ))
    }
}
