//
//  DMErrorHandling
//
//  Created by Mykola Dementiev
//

import SwiftUI

internal enum DMSuccessViewOwnSettings {
    static let containerViewTag: Int = 3100
    static let imageTag: Int = 3101
    static let textTag: Int = 3102
}

internal struct DMSuccessView: View {
    internal let settingsProvider: DMSuccessViewSettings
    internal let assosiatedObject: DMLoadableTypeSuccess?
    
    internal init(settings settingsProvider: DMSuccessViewSettings,
                  assosiatedObject: DMLoadableTypeSuccess? = nil) {
        self.settingsProvider = settingsProvider
        self.assosiatedObject = assosiatedObject
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
                .tag(DMSuccessViewOwnSettings.imageTag)
            
            let successTextProperties = settingsProvider.successTextProperties
            if let successText = assosiatedObject?.description ?? successTextProperties.text {
                Text(successText)
                    .foregroundColor(successTextProperties.foregroundColor)
                    .tag(DMSuccessViewOwnSettings.textTag)
            }
        }
        .tag(DMSuccessViewOwnSettings.containerViewTag)
    }
}
