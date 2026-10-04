//
//  DMUnLoader
//
//  Created by Mykola Dementiev
//
// take a look for details: https://stackoverflow.com/a/56496896/6643923

import SwiftUI

/// A custom SwiftUI view that displays a progress indicator with optional text.
/// This view uses a settings provider to configure the appearance of the progress view.
struct DMProgressView: View {
    let settingsProvider: any DMProgressViewSettings

    @Environment(\.hudTexts) private var hudTexts

    init(settings settingsProvider: any DMProgressViewSettings) {
        self.settingsProvider = settingsProvider
    }
    
    var body: some View {
        let geometry = settingsProvider.frameGeometrySize
        let loadingTextProperties = settingsProvider.loadingTextProperties
        let progressIndicatorProperties = settingsProvider.progressIndicatorProperties
        
        let minSize: CGFloat = 30
        ZStack(alignment: .center) {
            Color(settingsProvider.loadingContainerBackgroundColor)
            VStack {
                Text(HUDDefaultText.loadingText.displayed(loadingTextProperties.text, using: hudTexts))
                    .multilineTextAlignment(loadingTextProperties.alignment)
                    .foregroundColor(loadingTextProperties.foregroundColor)
                    .font(loadingTextProperties.font)
                    .lineLimit(loadingTextProperties.lineLimit)
                    .padding(loadingTextProperties.linePadding)
                
                ProgressView()
                    .controlSize(progressIndicatorProperties.size)
                    .progressViewStyle(progressIndicatorProperties.style)
                    .tint(progressIndicatorProperties.tintColor)
                    .layoutPriority(1)
            }
        }
        .frame(minWidth: minSize,
               maxWidth: geometry.width / 2,
               minHeight: minSize,
               maxHeight: geometry.height / 2)
        .fixedSize()
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
