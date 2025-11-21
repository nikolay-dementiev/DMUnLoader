//
//  DMUnLoader
//
//  Created by Mykola Dementiev
//

import SwiftUI

/// A namespace for constants used in the `DMSuccessView`.
/// These constants define unique tags for views within the success view.
enum DMSuccessViewOwnSettings {
    
    /// The tag assigned to the container view that holds all content in the success view.
    static let containerViewTag: Int = 3100
    
    /// The tag assigned to the image view displayed in the success view.
    static let imageTag: Int = 3101
    
    /// The tag assigned to the text view displayed in the success view.
    static let textTag: Int = 3102
}

/// A custom SwiftUI view that displays a success state with an image and optional text.
/// This view uses a settings provider to configure the appearance of the success view.
struct DMSuccessView: View {
    
    let settingsProvider: DMSuccessViewSettings
    let assosiatedObject: DMLoadableTypeSuccess?
    
    init(settings settingsProvider: DMSuccessViewSettings,
         assosiatedObject: DMLoadableTypeSuccess? = nil) {
        self.settingsProvider = settingsProvider
        self.assosiatedObject = assosiatedObject
    }
    
    var body: some View {
        let successImageProperties = settingsProvider.successImageProperties
        
        VStack(spacing: settingsProvider.spacingBetweenElements) {
            successImageProperties.image
                .resizable()
                .frame(width: successImageProperties.frame.width,
                       height: successImageProperties.frame.height,
                       alignment: successImageProperties.frame.alignment)
                .foregroundColor(successImageProperties.foregroundColor)
                .tag(DMSuccessViewOwnSettings.imageTag)
            
            let successTextProperties = settingsProvider.successTextProperties
            if let successText = assosiatedObject?.description ?? successTextProperties.text {
                Text(successText)
                    .foregroundColor(successTextProperties.foregroundColor)
                    .frame(alignment: successTextProperties.alignment)
                    .tag(DMSuccessViewOwnSettings.textTag)
            }
        }
        .tag(DMSuccessViewOwnSettings.containerViewTag)
    }
}

#Preview("DefaultSettings") {
    PreviewRenderOwner {
        DMSuccessView(settings: DMSuccessDefaultViewSettings())
    }
}

#Preview("CustomSettings") {
    PreviewRenderOwner {
        DMSuccessView(settings: DMSuccessDefaultViewSettings(
            successImageProperties: .init(
                image: Image(systemName: "checkmark.seal.fill"),
                frame: .init(width: 120, height: 120, alignment: .center),
                foregroundColor: .cyan
            ),
            successTextProperties: .init(
                text: "Operation Completed Successfully Operation Completed Successfully!",
                foregroundColor: .yellow,
                alignment: .center
            ),
            spacingBetweenElements: 20
        ))
    }
}
