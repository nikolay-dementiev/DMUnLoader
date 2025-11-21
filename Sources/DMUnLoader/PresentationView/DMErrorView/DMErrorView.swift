//
//  DMUnLoader
//
//  Created by Mykola Dementiev
//

import SwiftUI

/// A namespace for constants used in the `DMErrorView`.
/// These constants define unique tags for views within the error view.
enum DMErrorViewOwnSettings {
    
    /// The tag assigned to the vertical stack view (`VStack`) that holds all content in the error view.
    static let containerVStackViewTag: Int = 3010
    
    /// The tag assigned to the image view displayed in the error view.
    static let imageViewTag: Int = 3020
    
    /// The tag assigned to the error text view displayed in the error view.
    static let errorTextViewTag: Int = 3031
    
    /// The tag assigned to the container view for the error text derived from the exception.
    static let errorTextFormExeptionContainerViewTag: Int = 3040
    
    /// The tag assigned to the horizontal stack view (`HStack`) that organizes the action buttons.
    static let buttonContainersHStackViewTag: Int = 3050
    
    /// The tag assigned to the "Close" action button.
    static let actionButtonCloseViewTag: Int = 3051
    
    /// The tag assigned to the "Retry" action button.
    static let actionButtonRetryViewTag: Int = 3052
    
    /// The tag assigned to the generic button view.
    static let actionButtonButtoViewTag: Int = 3059
}

/// A custom SwiftUI view that displays an error state with an image, error text, and optional action buttons.
/// This view uses a settings provider to configure the appearance of the error view.
struct DMErrorView: View {
    let settingsProvider: DMErrorViewSettings
    let error: Error
    let onRetry: DMAction?
    let onClose: DMAction
    
#if DEBUG
    let inspection: Inspection<Self>? = getInspectionIfAvailable()
#endif
    
    init(settings settingsProvider: DMErrorViewSettings,
         error: Error,
         onRetry: DMAction? = nil,
         onClose: DMAction) {
        
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
                .tag(DMErrorViewOwnSettings.imageViewTag)
            
            if let errorText = settingsProvider.errorText {
                ErrorText(errorText,
                          settings: textSettings)
                .tag(DMErrorViewOwnSettings.errorTextViewTag)
            }
            
            ErrorText(error.localizedDescription,
                      settings: settingsProvider.errorTextSettings)
            .tag(DMErrorViewOwnSettings.errorTextFormExeptionContainerViewTag)
            
            let closeButtonSettings = settingsProvider.actionButtonCloseSettings
            HStack {
                ActionButton(settings: closeButtonSettings,
                             action: onClose)
                .tag(DMErrorViewOwnSettings.actionButtonCloseViewTag)
                
                if let onRetry = onRetry {
                    let retryButtonSettings = settingsProvider.actionButtonRetrySettings
                    
                    ActionButton(settings: retryButtonSettings,
                                 action: onRetry)
                    .tag(DMErrorViewOwnSettings.actionButtonRetryViewTag)
                }
            }
            .padding(.top, 5)
            .tag(DMErrorViewOwnSettings.buttonContainersHStackViewTag)
        }
        .tag(DMErrorViewOwnSettings.containerVStackViewTag)
        
#if DEBUG
        .onReceive(inspection?.notice ?? EmptyPublisher().notice) { [weak inspection] in
            inspection?.visit(self, $0)
        }
#endif
    }
}

extension DMErrorView {
    
    struct ActionButton: View {
        let action: DMAction
        let settings: ActionButtonSettings
        
        init(settings: ActionButtonSettings,
             action: DMAction) {
            self.action = action
            self.settings = settings
        }
        
        var body: some View {
            Button(settings.text,
                   action: action.simpleAction)
            .buttonStyle(settings.styleFactory())
            .tag(DMErrorViewOwnSettings.actionButtonButtoViewTag)
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
                .tag(DMErrorViewOwnSettings.errorTextViewTag)
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
            errorText: "An error has occured! An error has occured! An error has occured! An error has occured!",
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
            errorText: "An error has occured! An error has occured! An error has occured! An error has occured!",
            actionButtonCloseSettings: .init(
                text: "X"
                )
        ),
                    error: DMAppError.custom("Something went wrong Something went wrong Something went wrong"),
                    onClose: DMButtonAction({ _ in }))
    }
}
