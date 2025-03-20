//
//  DMErrorHandling
//
//  Created by Mykola Dementiev
//

import SwiftUI

/// A namespace for constants used in the `DMErrorView`.
/// These constants define unique tags for views within the error view.
internal enum DMErrorViewOwnSettings {
    
    /// The tag assigned to the vertical stack view (`VStack`) that holds all content in the error view.
    static let containerVStackViewTag: Int = 3010
    
    /// The tag assigned to the image view displayed in the error view.
    static let imageViewTag: Int = 3020
    
    /// The tag assigned to the container view for the error text provided by the settings provider.
    static let errorTextFormProviderContainerViewTag: Int = 3030
    
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
internal struct DMErrorView: View {
    
    /// The settings provider responsible for configuring the error view's appearance.
    internal let settingsProvider: DMErrorViewSettings
    
    /// The error that occurred.
    internal let error: Error
    
    /// An optional action to retry the operation.
    internal let onRetry: DMAction?
    
    /// An action to close the error view.
    internal let onClose: DMAction
    
    /// Initializes a new instance of `DMErrorView`.
    /// - Parameters:
    ///   - settingsProvider: The settings provider responsible for configuring the error view's appearance.
    ///   - error: The error that occurred.
    ///   - onRetry: An optional action to retry the operation. Defaults to `nil`.
    ///   - onClose: An action to close the error view.
    /// - Example:
    ///   ```swift
    ///   let settings = DMErrorDefaultViewSettings()
    ///   let error = NSError(domain: "Example", code: 404, userInfo: nil)
    ///   let onClose = DMButtonAction({ _ in })
    ///   let errorView = DMErrorView(settings: settings, error: error, onClose: onClose)
    ///   ```
    internal init(settings settingsProvider: DMErrorViewSettings,
                  error: Error,
                  onRetry: DMAction? = nil,
                  onClose: DMAction) {
        self.settingsProvider = settingsProvider
        self.error = error
        self.onRetry = onRetry
        self.onClose = onClose
    }
    
    /// The body of the `DMErrorView`.
    /// - Returns: A view that displays an error image, error text, and optional action buttons based on the provided settings.
    /// - Behavior:
    ///   - Displays an image configured by `errorImageSettings`.
    ///   - Displays optional error text provided by the settings provider or derived from the exception.
    ///   - Displays "Close" and "Retry" buttons if actions are provided.
    internal var body: some View {
        
        let imageSettings = settingsProvider.errorImageSettings
        VStack {
            imageSettings.image
                .resizable()
                .frame(width: imageSettings.frameSize.width,
                       height: imageSettings.frameSize.height)
                .foregroundColor(imageSettings.foregroundColor)
                .tag(DMErrorViewOwnSettings.imageViewTag)
            
            if let errorText = settingsProvider.errorText {
                ErrorText(errorText,
                          settings: settingsProvider.errorTextSettings)
                .tag(DMErrorViewOwnSettings.errorTextFormProviderContainerViewTag)
            }
            
            ErrorText(error.localizedDescription,
                      settings: settingsProvider.errorTextSettings)
            .tag(DMErrorViewOwnSettings.errorTextFormExeptionContainerViewTag)
            
            HStack {
                ActionButton(settings: settingsProvider.actionButtonCloseSettings,
                             action: onClose)
                .tag(DMErrorViewOwnSettings.actionButtonCloseViewTag)
                if let onRetry = onRetry {
                    ActionButton(settings: settingsProvider.actionButtonRetrySettings,
                                 action: onRetry)
                    .tag(DMErrorViewOwnSettings.actionButtonRetryViewTag)
                }
            }
            .tag(DMErrorViewOwnSettings.buttonContainersHStackViewTag)
        }
        .tag(DMErrorViewOwnSettings.containerVStackViewTag)
    }
}

internal extension DMErrorView {
    
    /// A custom SwiftUI view representing an action button in the error view.
    struct ActionButton: View {
        
        /// The action to perform when the button is tapped.
        let action: DMAction
        
        /// The settings that configure the appearance of the button.
        let settings: ActionButtonSettings
        
        /// Initializes a new instance of `ActionButton`.
        /// - Parameters:
        ///   - settings: The settings that configure the appearance of the button.
        ///   - action: The action to perform when the button is tapped.
        internal init(settings: ActionButtonSettings,
                      action: DMAction) {
            self.action = action
            self.settings = settings
        }
        
        /// The body of the `ActionButton`.
        /// - Returns: A styled button with the specified text, background color, and corner radius.
        var body: some View {
            Button(settings.text,
                   action: action.simpleAction)
            .padding()
            .background(settings.backgroundColor)
            .cornerRadius(settings.cornerRadius)
            .tag(DMErrorViewOwnSettings.actionButtonButtoViewTag)
        }
    }
    
    /// A custom SwiftUI view representing error text in the error view.
    struct ErrorText: View {
        
        /// The error text to display.
        let errorText: String
        
        /// The settings that configure the appearance of the text.
        let settings: ErrorTextSettings
        
        /// Initializes a new instance of `ErrorText`.
        /// - Parameters:
        ///   - errorText: The error text to display.
        ///   - settings: The settings that configure the appearance of the text.
        internal init(_ errorText: String,
                      settings: ErrorTextSettings) {
            self.errorText = errorText
            self.settings = settings
        }
        
        /// The body of the `ErrorText`.
        /// - Returns: Styled text with the specified foreground color, alignment, and padding.
        var body: some View {
            Text(errorText)
                .foregroundColor(settings.foregroundColor)
                .multilineTextAlignment(settings.multilineTextAlignment)
                .padding(settings.padding)
                .tag(DMErrorViewOwnSettings.errorTextViewTag)
        }
    }
}
