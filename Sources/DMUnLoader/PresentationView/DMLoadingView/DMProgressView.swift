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
}

/// A custom SwiftUI view that displays a progress indicator with optional text.
/// This view uses a settings provider to configure the appearance of the progress view.
struct DMProgressView: View {
    
    /// The settings provider responsible for configuring the progress view's appearance.
    let settingsProvider: DMLoadingViewSettings
    
    /// Initializes a new instance of `DMProgressView`.
    /// - Parameter settingsProvider: The settings provider responsible for configuring the progress view's appearance.
    /// - Example:
    ///   ```swift
    ///   let settings = DMLoadingDefaultViewSettings()
    ///   let progressView = DMProgressView(settings: settings)
    ///   ```
    init(settings settingsProvider: DMLoadingViewSettings) {
        self.settingsProvider = settingsProvider
    }
    
    /// The body of the `DMProgressView`.
    /// - Returns: A view that displays a progress indicator and optional text based on the provided settings.
    /// - Behavior:
    ///   - Displays a `ProgressView` styled as a circular progress indicator.
    ///   - Displays optional text derived from the `loadingTextProperties` of the settings provider.
    ///   - Ensures the layout adapts dynamically based on the provided geometry and constraints.
    var body: some View {
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
