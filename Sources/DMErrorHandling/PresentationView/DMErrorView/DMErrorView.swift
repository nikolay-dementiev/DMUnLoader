//
//  DMErrorHandling
//
//  Created by Mykola Dementiev
//

import SwiftUI

// TODO: adopt all for accesssability
// https://developer.apple.com/videos/play/wwdc2021/10119
// https://developer.apple.com/videos/play/wwdc2019/238

internal enum DMErrorViewOwnSettings {
    static let containerVStackViewTag: Int = 3010
    static let imageViewTag: Int = 3020
    static let errorTextFormProviderContainerViewTag: Int = 3030
    static let errorTextViewTag: Int = 3031
    static let errorTextFormExeptionContainerViewTag: Int = 3040
    static let buttonContainersHStackViewTag: Int = 3050
    static let actionButtonCloseViewTag: Int = 3051
    static let actionButtonRetryViewTag: Int = 3052
    static let actionButtonButtoViewTag: Int = 3059
}

internal struct DMErrorView: View {
    
    internal let settingsProvider: DMErrorViewSettings
    
    internal let error: Error
    internal let onRetry: DMAction?
    internal let onClose: DMAction

    internal init(settings settingsProvider: DMErrorViewSettings,
                  error: Error,
                  onRetry: DMAction? = nil,
                  onClose: DMAction) {
        self.settingsProvider = settingsProvider
        self.error = error
        self.onRetry = onRetry
        self.onClose = onClose
    }
    
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
                             action: onClose.simpleAction)
                .tag(DMErrorViewOwnSettings.actionButtonCloseViewTag)

                if let onRetry = onRetry {
                    ActionButton(settings: settingsProvider.actionButtonRetrySettings,
                                 action: onRetry.simpleAction)
                    .tag(DMErrorViewOwnSettings.actionButtonRetryViewTag)
                }
            }
            .tag(DMErrorViewOwnSettings.buttonContainersHStackViewTag)
        }
        .tag(DMErrorViewOwnSettings.containerVStackViewTag)
    }
    
    private struct ActionButton: View {
        let action: () -> Void
        let settings: ActionButtonSettings
        
        internal init(settings: ActionButtonSettings,
                      action: @escaping () -> Void) {
            self.action = action
            self.settings = settings
        }
        
        var body: some View {
            Button(settings.text,
                   action: action)
            .padding()
            .background(settings.backgroundColor)
            .cornerRadius(settings.cornerRadius)
            .tag(DMErrorViewOwnSettings.actionButtonButtoViewTag)
        }
    }
    
    private struct ErrorText: View {
        let errorText: String
        let settings: ErrorTextSettings
        
        internal init(_ errorText: String,
                      settings: ErrorTextSettings) {
            self.errorText = errorText
            self.settings = settings
        }
        
        var body: some View {
            Text(errorText)
                .foregroundColor(settings.foregroundColor)
                .multilineTextAlignment(settings.multilineTextAlignment)
                .padding(settings.padding)
                .tag(DMErrorViewOwnSettings.errorTextViewTag)
        }
    }
}
