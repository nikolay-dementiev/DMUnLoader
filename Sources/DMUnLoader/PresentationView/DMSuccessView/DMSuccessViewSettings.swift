//
//  DMUnLoader
//
//  Created by Mykola Dementiev
//

import SwiftUI

/// A protocol defining settings for a success view (`DMSuccessView`).
/// Conforming types must provide properties for the success image and text.
public protocol DMSuccessViewSettings {
    
    /// Properties related to the success image displayed in the success view.
    var successImageProperties: SuccessImageProperties { get }
    
    /// Properties related to the success text displayed in the success view.
    var successTextProperties: SuccessTextProperties { get }
}

/// A concrete implementation of the `DMSuccessViewSettings` protocol.
/// This struct provides default settings for a success view, with customizable properties.
public struct DMSuccessDefaultViewSettings: DMSuccessViewSettings {
    
    /// Properties related to the success image displayed in the success view.
    public let successImageProperties: SuccessImageProperties
    
    /// Properties related to the success text displayed in the success view.
    public let successTextProperties: SuccessTextProperties
    
    /// Initializes a new instance of `DMSuccessDefaultViewSettings` with optional customizations.
    /// - Parameters:
    ///   - successImageProperties: The properties for the success image. Defaults to `SuccessImageProperties()`.
    ///   - successTextProperties: The properties for the success text. Defaults to `SuccessTextProperties()`.
    /// - Example:
    ///   ```swift
    ///   let customSuccessSettings = DMSuccessDefaultViewSettings(
    ///       successImageProperties: SuccessImageProperties(image: Image(systemName: "star.fill"), foregroundColor: .yellow),
    ///       successTextProperties: SuccessTextProperties(text: "Operation Completed!", foregroundColor: .black)
    ///   )
    ///   ```
    public init(successImageProperties: SuccessImageProperties = SuccessImageProperties(),
                successTextProperties: SuccessTextProperties = SuccessTextProperties()) {
        
        self.successImageProperties = successImageProperties
        self.successTextProperties = successTextProperties
    }
}

/// A struct defining properties for the success image displayed in a success view.
public struct SuccessImageProperties {
    
    /// The image to display as the success icon.
    public var image: Image
    
    /// The size of the image frame.
    public var frame: CustomSizeView
    
    /// The foreground color of the image.
    public var foregroundColor: Color?
    
    /// Initializes a new instance of `SuccessImageProperties` with optional customizations.
    /// - Parameters:
    ///   - image: The image to display. Defaults to a checkmark circle icon (`"checkmark.circle.fill"`).
    ///   - frame: The size of the image frame. Defaults to `CustomSizeView(width: 50, height: 50)`.
    ///   - foregroundColor: The foreground color of the image. Defaults to `.green`.
    /// - Example:
    ///   ```swift
    ///   let customImageProperties = SuccessImageProperties(
    ///       image: Image(systemName: "star.fill"),
    ///       frame: CustomSizeView(width: 60, height: 60),
    ///       foregroundColor: .yellow
    ///   )
    ///   ```
    public init(
        image: Image = Image(systemName: "checkmark.circle.fill"),
        frame: CustomSizeView = .init(width: 50, height: 50),
        foregroundColor: Color? = .green
    ) {
        self.image = image
        self.frame = frame
        self.foregroundColor = foregroundColor
    }
}

/// A struct defining properties for the success text displayed in a success view.
public struct SuccessTextProperties {
    
    /// The text to display as the success message.
    public var text: String?
    
    /// The foreground color of the text.
    public var foregroundColor: Color?
    
    /// Initializes a new instance of `SuccessTextProperties` with optional customizations.
    /// - Parameters:
    ///   - text: The text to display. Defaults to `"Success!"`.
    ///   - foregroundColor: The foreground color of the text. Defaults to `.white`.
    /// - Example:
    ///   ```swift
    ///   let customTextProperties = SuccessTextProperties(
    ///       text: "Operation Completed!",
    ///       foregroundColor: .black
    ///   )
    ///   ```
    public init(
        text: String? = "Success!",
        foregroundColor: Color? = .white
    ) {
        self.text = text
        self.foregroundColor = foregroundColor
    }
}
