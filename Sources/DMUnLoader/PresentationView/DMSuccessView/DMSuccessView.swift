//
//  DMUnLoader
//
//  Created by Mykola Dementiev
//

import SwiftUI

/// A namespace for constants used in the `DMSuccessView`.
/// These constants define unique tags for views within the success view.
internal enum DMSuccessViewOwnSettings {
    
    /// The tag assigned to the container view that holds all content in the success view.
    static let containerViewTag: Int = 3100
    
    /// The tag assigned to the image view displayed in the success view.
    static let imageTag: Int = 3101
    
    /// The tag assigned to the text view displayed in the success view.
    static let textTag: Int = 3102
}

/// A custom SwiftUI view that displays a success state with an image and optional text.
/// This view uses a settings provider to configure the appearance of the success view.
internal struct DMSuccessView: View {
    
    /// The settings provider responsible for configuring the success view's appearance.
    internal let settingsProvider: DMSuccessViewSettings
    
    /// An optional object associated with the success state, providing additional context or a custom message.
    internal let assosiatedObject: DMLoadableTypeSuccess?
    
    /// Initializes a new instance of `DMSuccessView`.
    /// - Parameters:
    ///   - settingsProvider: The settings provider responsible for configuring the success view's appearance.
    ///   - assosiatedObject: An optional object associated with the success state. Defaults to `nil`.
    /// - Example:
    ///   ```swift
    ///   let settings = DMSuccessDefaultViewSettings()
    ///   let successView = DMSuccessView(settings: settings, assosiatedObject: "Operation Completed!")
    ///   ```
    internal init(settings settingsProvider: DMSuccessViewSettings,
                  assosiatedObject: DMLoadableTypeSuccess? = nil) {
        self.settingsProvider = settingsProvider
        self.assosiatedObject = assosiatedObject
    }
    
    /// The body of the `DMSuccessView`.
    /// - Returns: A view that displays a success image and optional text based on the provided settings and associated object.
    /// - Behavior:
    ///   - Displays a resizable image with properties defined in `successImageProperties`.
    ///   - Displays optional text derived from the `assosiatedObject` or `successTextProperties`.
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
