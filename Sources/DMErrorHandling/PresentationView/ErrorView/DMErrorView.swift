//
//  File.swift
//  DMErrorHandling
//
//  Created by Nikolay Dementiev on 16.01.2025.
//

import SwiftUI

// This protocol restponsible to provide settings for ProgressView
public protocol DMErrorViewSettings {
    var errorImage: Image { get }
    var errorText: String? { get }
}

//default implementation of settings
internal struct DMErrorDefaultViewSettings: DMErrorViewSettings {
    internal let errorImage: Image
    internal let errorText: String?
    
    public init(errorImage: Image = Image(systemName: "exclamationmark.triangle"),
                errorText: String? = "An error has occured") {
        
        self.errorImage = errorImage
        self.errorText = errorText
    }
}

//TODO: adopt all for accesssability
//https://developer.apple.com/videos/play/wwdc2021/10119
//https://developer.apple.com/videos/play/wwdc2019/238

internal struct DMErrorView: View {
    
    internal let settingsProvider: DMErrorViewSettings
    
    internal let error: Error
    internal let onRetry: (() -> Void)?
    internal let onClose: () -> Void

    /// provides an initializer for instance.
    /// - Parameter settingsProvider: the settings used to set this view.
    /// In case this parameter is not provided - it will be used as default settings by calling
    /// `Self.getSettingsProvider()` by `LoadingViewScene` protocol responsibility
    internal init(settings settingsProvider: DMErrorViewSettings,
                  error: Error,
                  onRetry: (() -> Void)? = nil,
                  onClose: @escaping () -> Void) {
        self.settingsProvider = settingsProvider
        self.error = error
        self.onRetry = onRetry
        self.onClose = onClose
    }
    
    internal var body: some View {
        
        VStack {
            settingsProvider.errorImage
                .resizable()
                .frame(width: 50, height: 50)
                .foregroundColor(.red)
            
            if let errorText = settingsProvider.errorText {
                ErrorText(errorText)
            }
            
            ErrorText(error.localizedDescription)
            
            HStack {
                //TODO: connect CloseButtonView and check layout
                /*
                CloseButtonView {
                    self.presentationMode.wrappedValue.dismiss()
                }*/
                ActionButton(text: "Close", action: onClose)

                //TODO: obtain all variables from `settingsProvider`
                if let onRetry = onRetry {
                    ActionButton(text: "Retry", action: onRetry)
                }
            }
        }
    }
    
    private struct ActionButton: View {
        let action: () -> Void
        let buttonText: String
        
        internal init(text buttonText: String, action: @escaping () -> Void) {
            self.action = action
            self.buttonText = buttonText
        }
        
        var body: some View {
            Button(buttonText, action: action)
            .padding()
            .background(Color.white)
            .cornerRadius(8)
        }
    }
    
    private struct ErrorText: View {
        let errorText: String
        
        internal init(_ errorText: String) {
            self.errorText = errorText
        }
        
        var body: some View {
            Text(errorText)
                .foregroundColor(.white)
                .multilineTextAlignment(.center)
                .padding(EdgeInsets(top: 0, leading: 10, bottom: 0, trailing: 10))
        }
    }
}


//#Preview {
//    ErrorView(error: DMAppError.custom(errorDescription: "Some error Test"),
//              onRetry: nil)
//}
