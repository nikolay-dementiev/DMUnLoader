//
//  DMUnLoader
//
//  Created by Mykola Dementiev
//

import SwiftUI

/// A custom SwiftUI view that displays a success state with an image and optional text.
/// This view uses a settings provider to configure the appearance of the success view.
struct DMSuccessView: View {
    
    let settingsProvider: any DMSuccessViewSettings
    let assosiatedObject: (any DMLoadableTypeSuccess)?
    
    init(settings settingsProvider: any DMSuccessViewSettings,
         assosiatedObject: (any DMLoadableTypeSuccess)? = nil) {
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
                .hiddenFromAccessibility(if: successImageProperties.showsTheDefaultImage)
            
            let successTextProperties = settingsProvider.successTextProperties
            if let successText = assosiatedObject?.description ?? successTextProperties.text {
                Text(successText)
                    .multilineTextAlignment(successTextProperties.lineAlignment)
                    .foregroundColor(successTextProperties.foregroundColor)
                    .frame(alignment: successTextProperties.alignment)
            }
        }
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
