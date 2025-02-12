//
//  DMSuccessView.swift
//  DMErrorHandling
//
//  Created by Nikolay Dementiev on 28.01.2025.
//

import SwiftUI

internal struct DMSuccessView: View {
    internal let assosiatedObject: DMLoadableTypeSuccess?
    internal let settingsProvider: DMSuccessViewSettings
    
    internal init(settings settingsProvider: DMSuccessViewSettings,
                  assosiatedObject: DMLoadableTypeSuccess) {
        self.assosiatedObject = assosiatedObject
        self.settingsProvider = settingsProvider
    }
    
    internal var body: some View {
        let successImageProperties = settingsProvider.successImageProperties
        VStack {
            successImageProperties.image
                .resizable()
                .frame(width: successImageProperties.frame.width,
                       height: successImageProperties.frame.height,
                       alignment: successImageProperties.frame.alignment)
                .foregroundColor(successImageProperties.foregroundColor)
            
            let successTextProperties = settingsProvider.successTextProperties
            if let successText = assosiatedObject?.description ?? successTextProperties.text {
                Text(successText)
                    .foregroundColor(successTextProperties.foregroundColor)
            }
        }
    }
}
