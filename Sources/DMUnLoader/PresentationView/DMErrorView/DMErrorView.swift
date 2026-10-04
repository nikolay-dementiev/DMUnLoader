//
//  DMUnLoader
//
//  Created by Mykola Dementiev
//

import SwiftUI

/// A custom SwiftUI view that displays an error state with an image, error text, and optional action buttons.
/// This view uses a settings provider to configure the appearance of the error view.
struct DMErrorView: View {
    let settingsProvider: any DMErrorViewSettings
    let error: any Error
    let onRetry: (any DMAction)?
    let onClose: any DMAction

    @Environment(\.hudTexts) private var hudTexts

    init(settings settingsProvider: any DMErrorViewSettings,
         error: any Error,
         onRetry: (any DMAction)? = nil,
         onClose: any DMAction) {
        
        self.settingsProvider = settingsProvider
        self.error = error
        self.onRetry = onRetry
        self.onClose = onClose
    }
    
    var body: some View {
        let imageSettings = settingsProvider.errorImageSettings
        let textSettings = settingsProvider.errorTextSettings
        
        VStack {
            imageSettings.image
                .resizable()
                .frame(width: imageSettings.frameSize.width,
                       height: imageSettings.frameSize.height,
                       alignment: imageSettings.frameSize.alignment)
                .foregroundStyle(imageSettings.foregroundColor)
                .hiddenFromAccessibility(if: imageSettings.showsTheDefaultImage)
            
            if let errorText = settingsProvider.errorText {
                ErrorText(HUDDefaultText.failureTitle.displayed(errorText, using: hudTexts),
                          settings: textSettings)
            }

            ErrorText(error.localizedDescription,
                      settings: settingsProvider.errorTextSettings)

            let closeButtonSettings = settingsProvider.actionButtonCloseSettings
            HStack {
                ActionButton(settings: closeButtonSettings,
                             title: HUDDefaultText.failureClose.displayed(closeButtonSettings.text, using: hudTexts),
                             action: onClose)

                if let onRetry = onRetry {
                    let retryButtonSettings = settingsProvider.actionButtonRetrySettings

                    ActionButton(settings: retryButtonSettings,
                                 title: HUDDefaultText.failureRetry.displayed(retryButtonSettings.text, using: hudTexts),
                                 action: onRetry)
                }
            }
            .padding(.top, 5)
        }
    }
}

extension DMErrorView {
    
    struct ActionButton: View {
        let action: any DMAction
        let settings: ActionButtonSettings
        let title: String

        init(settings: ActionButtonSettings,
             title: String,
             action: any DMAction) {
            self.action = action
            self.settings = settings
            self.title = title
        }

        var body: some View {
            Button(title,
                   action: action.simpleAction)
            .buttonStyle(settings.styleFactory())
        }
    }
    
    struct ErrorText: View {
        let errorText: String
        let settings: ErrorTextSettings
        
        init(_ errorText: String,
             settings: ErrorTextSettings) {
            self.errorText = errorText
            self.settings = settings
        }
        
        var body: some View {
            Text(errorText)
                .foregroundStyle(settings.foregroundColor)
                .multilineTextAlignment(settings.multilineTextAlignment)
                .padding(settings.padding)
        }
    }
}

#Preview("DefaultSettings") {
    PreviewRenderOwner {
        DMErrorView(settings: DMErrorDefaultViewSettings(),
                    error: DMAppError.custom(
                        "Something went wrong"
                    ),
                    onClose: DMButtonAction {}
        )
    }
}

#Preview("2 buttons") {
    PreviewRenderOwner {
        DMErrorView(settings: DMErrorDefaultViewSettings(
            errorText: "An error has occurred! An error has occurred! An error has occurred! An error has occurred!",
            actionButtonCloseSettings: .init(
                text: "X"
                )
                
        ),
                    error: DMAppError.custom("Something went wrong Something went wrong Something went wrong"),
                    onRetry: DMButtonAction({ _ in }),
                    onClose: DMButtonAction({ _ in }))
    }
}

#Preview("1 button") {
    PreviewRenderOwner {
        DMErrorView(settings: DMErrorDefaultViewSettings(
            errorText: "An error has occurred! An error has occurred! An error has occurred! An error has occurred!",
            actionButtonCloseSettings: .init(
                text: "X"
                )
        ),
                    error: DMAppError.custom("Something went wrong Something went wrong Something went wrong"),
                    onClose: DMButtonAction({ _ in }))
    }
}
