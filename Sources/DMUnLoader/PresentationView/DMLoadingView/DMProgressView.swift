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
    @Environment(\.hudAppearance) private var appearance

    init(settings settingsProvider: any DMProgressViewSettings) {
        self.settingsProvider = settingsProvider
    }

    var body: some View {
        switch appearance.kind {
        case .standard:
            standardBody
        case .accessible:
            accessibleBody
        }
    }

    /// The accessible look has no cap: the text wraps at the width the card offers and shows in full,
    /// whatever the text size and the language, and the view is as tall as the text needs.
    private var accessibleBody: some View {
        let loadingTextProperties = settingsProvider.loadingTextProperties
        let progressIndicatorProperties = settingsProvider.progressIndicatorProperties

        return VStack {
            Text(HUDDefaultText.loadingText.displayed(loadingTextProperties.text, using: hudTexts))
                .multilineTextAlignment(loadingTextProperties.alignment)
                .foregroundColor(loadingTextProperties.foregroundColor)
                .font(loadingTextProperties.font)
                .lineLimit(loadingTextProperties.lineLimit)
                .padding(loadingTextProperties.linePadding)
                .fixedSize(horizontal: false, vertical: true)

            ProgressView()
                .controlSize(progressIndicatorProperties.size)
                .progressViewStyle(progressIndicatorProperties.style)
                .tint(progressIndicatorProperties.tintColor)
                .layoutPriority(1)
        }
        // No flexible frame: one with a minimum size reports the height it is offered when the content
        // is taller, so the card could not tell that the text does not fit and would draw it past
        // itself instead of scrolling it. The content is taller than 30 points anyway.
        .background(settingsProvider.loadingContainerBackgroundColor)
    }

    /// The look of every release so far: at most half of the frame geometry in each direction.
    @ViewBuilder
    private var standardBody: some View {
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
