//
//  DMUnLoader
//
//  Created by Mykola Dementiev
//

import SwiftUI

/// A protocol defining settings for a success view (`DMSuccessView`).
/// Conforming types must provide properties for the success image and text.
public protocol DMSuccessViewSettings {
    
    var spacingBetweenElements: CGFloat? { get }
    
    /// Properties related to the success image displayed in the success view.
    var successImageProperties: SuccessImageProperties { get }
    
    /// Properties related to the success text displayed in the success view.
    var successTextProperties: SuccessTextProperties { get }
}

/// A concrete implementation of the `DMSuccessViewSettings` protocol.
/// This struct provides default settings for a success view, with customizable properties.
public struct DMSuccessDefaultViewSettings: DMSuccessViewSettings {
    /// The spacing between the success image and text elements.
    public let spacingBetweenElements: CGFloat?
    
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
                successTextProperties: SuccessTextProperties = SuccessTextProperties(),
                spacingBetweenElements: CGFloat? = nil) {
        
        self.successImageProperties = successImageProperties
        self.successTextProperties = successTextProperties
        self.spacingBetweenElements = spacingBetweenElements
    }
}

extension DMSuccessDefaultViewSettings: Hashable {
    public static func == (lhs: Self, rhs: Self) -> Bool {
        lhs.hashValue == rhs.hashValue
    }
    
    public func hash(into hasher: inout Hasher) {
        hasher.combine(successImageProperties)
        hasher.combine(successTextProperties)
        hasher.combine(spacingBetweenElements)
    }
}

/// A struct defining properties for the success image displayed in a success view.
public struct SuccessImageProperties: Identifiable {
    public var id: UUID
    
    /// The image to display as the success icon.
    public let image: Image
    
    /// The size of the image frame.
    public let frame: CustomViewSize
    
    /// The foreground color of the image.
    public let foregroundColor: Color?
    
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
        id: UUID = UUID(),
        image: Image = Image(systemName: "checkmark.circle.fill"),
        frame: CustomViewSize = .init(width: 50, height: 50),
        foregroundColor: Color? = .green
    ) {
        self.id = id
        self.image = image
        self.frame = frame
        self.foregroundColor = foregroundColor
    }
}

extension SuccessImageProperties: Hashable {
    public static func == (lhs: SuccessImageProperties, rhs: SuccessImageProperties) -> Bool {
        lhs.hashValue == rhs.hashValue
    }
    
    public func hash(into hasher: inout Hasher) {
        hasher.combine(id)
        hasher.combine(frame)
        hasher.combine(foregroundColor)
    }
}

/// A struct defining properties for the success text displayed in a success view.
public struct SuccessTextProperties {
    
    /// The text to display as the success message.
    public let text: String?
    
    /// The foreground color of the text.
    public let foregroundColor: Color?
    
    public let alignment: Alignment
    
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
        foregroundColor: Color? = .white,
        alignment: Alignment = .center
    ) {
        self.text = text
        self.foregroundColor = foregroundColor
        self.alignment = alignment
    }
}

extension SuccessTextProperties: Hashable {
    public static func == (lhs: Self, rhs: Self) -> Bool {
        lhs.hashValue == rhs.hashValue
    }
    
    public func hash(into hasher: inout Hasher) {
        hasher.combine(text)
        hasher.combine(foregroundColor)
    }
}
