//
//  DMSuccessView.swift
//  DMErrorHandling
//
//  Created by Nikolay Dementiev on 28.01.2025.
//

import SwiftUI

// This protocol restponsible to provide settings for ProgressView
public protocol DMSuccessViewSettings {
    var successImage: Image { get }
    var successText: String? { get }
}

//default implementation of settings
internal struct DMSuccessDefaultViewSettings: DMSuccessViewSettings {
    var successImage: Image
    var successText: String?
    
    internal init(successImage: Image = Image(systemName: "checkmark.circle.fill"),
                  errorText: String? = "Успішно!") {
        self.successImage = successImage
        self.successText = errorText
    }
}

internal struct DMSuccessView: View {
    
    internal let assosiatedObject: Any?
    internal let settingsProvider: DMSuccessViewSettings
    
    internal init(settings settingsProvider: DMSuccessViewSettings,
                  assosiatedObject: Any? = nil) {
        self.assosiatedObject = assosiatedObject
        self.settingsProvider = settingsProvider
    }
    
    var body: some View {
        VStack {
            settingsProvider.successImage
                .resizable()
                .frame(width: 50, height: 50)
                .foregroundColor(.green)
            Text("\(String(describing: assosiatedObject as? String ?? settingsProvider.successText))")
                .foregroundColor(.white)
        }
    }
}
