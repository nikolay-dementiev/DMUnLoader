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


internal struct ErrorView: View, ErrorViewScene {
    
    internal let settingsProvider: DMErrorViewSettings
    
    internal let error: Error
    internal let onRetry: (() -> Void)?
    
    @Environment(\.presentationMode) private var presentationMode

    
    /// provides an initializer for instance.
    /// - Parameter settingsProvider: the settings used to set this view.
    /// In case this parameter is not provided - it will be used as default settings by calling
    /// `Self.getSettingsProvider()` by `LoadingViewScene` protocol responsibility
    internal init(settingsProvider: DMErrorViewSettings = Self.getSettingsProvider(),
                  error: Error,
                  onRetry: (() -> Void)? = nil) {
        self.settingsProvider = settingsProvider
        self.error = error
        self.onRetry = onRetry
    }
    
    internal var body: some View {
        //        VStack {
        //            //Image(.error)
        //            Text("An error has occured")
        //            Text(error.localizedDescription)
        //            Button("Retry") { onRetry?() }
        //        }
        VStack {
            settingsProvider.errorImage
                .resizable()
                .frame(width: 50, height: 50)
                .foregroundColor(.red)
            
            if let errorText = settingsProvider.errorText {
                Text(errorText)
                    .foregroundColor(.white)
                    .multilineTextAlignment(.center)
            }
            
            Text(error.localizedDescription)
                .foregroundColor(.white)
                .multilineTextAlignment(.center)
            
            HStack {
                CloseButtonView {
                    self.presentationMode.wrappedValue.dismiss()
                }
                .padding()
                .background(Color.white)
                .cornerRadius(8)
                
                //TODO: obtain all variables from `settingsProvider`
                if let onRetry = onRetry {
                    Button("Retry") {
                        onRetry()
                    }
                    .padding()
                    .background(Color.white)
                    .cornerRadius(8)
                }
            }
            
        }
    }
}


//#Preview {
//    ErrorView(error: DMAppError.custom(errorDescription: "Some error Test"),
//              onRetry: nil)
//}
