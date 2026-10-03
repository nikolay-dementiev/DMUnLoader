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
    /// Equal when every setting is equal: the image properties, the text properties and the
    /// spacing between them.
    public static func == (lhs: Self, rhs: Self) -> Bool {
        lhs.successImageProperties == rhs.successImageProperties
            && lhs.successTextProperties == rhs.successTextProperties
            && lhs.spacingBetweenElements == rhs.spacingBetweenElements
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
    /// Equal when the `id`, the image, the frame and the foreground color are equal. Two
    /// values made with the default `id` are different values.
    public static func == (lhs: SuccessImageProperties, rhs: SuccessImageProperties) -> Bool {
        lhs.id == rhs.id
            && lhs.image == rhs.image
            && lhs.frame == rhs.frame
            && lhs.foregroundColor == rhs.foregroundColor
    }

    /// Hashes the `id`, the frame and the foreground color. `Image` is not `Hashable`.
    public func hash(into hasher: inout Hasher) {
        hasher.combine(id)
        hasher.combine(frame)
        hasher.combine(foregroundColor)
    }
}

/// A struct defining properties for the success text displayed in a success view.
public struct SuccessTextProperties {
    
    /// The text of a success view that has no message. A success shown through a loading
    /// manager always has one, the message passed to `showSuccess(_:provider:)`, and the
    /// success view shows its `description` instead. A custom success view may read this text.
    public let text: String?

    /// The foreground color of the text.
    public let foregroundColor: Color?

    /// How the lines of the text line up when it takes more than one line. The horizontal
    /// part decides: `.leading` and `.trailing` line them up at that edge, any other
    /// horizontal alignment centers them. The vertical part has no effect. A single line is
    /// centered in the success view whatever this value is.
    public let alignment: Alignment

    /// Creates the properties of the success text.
    /// - Parameters:
    ///   - text: The text shown when the success has no message. Defaults to `"Success!"`.
    ///   - foregroundColor: The color of the text. Defaults to `.white`.
    ///   - alignment: How the lines of a text of more than one line line up; see `alignment`.
    ///     Defaults to `.center`.
    /// - Example:
    ///   ```swift
    ///   let success = SuccessTextProperties(text: "Saved", alignment: .leading)
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
    /// Equal when the text, the foreground color and the alignment are equal.
    public static func == (lhs: Self, rhs: Self) -> Bool {
        lhs.text == rhs.text
            && lhs.foregroundColor == rhs.foregroundColor
            && lhs.alignment == rhs.alignment
    }

    /// Hashes the text and the foreground color. `Alignment` is not `Hashable`.
    public func hash(into hasher: inout Hasher) {
        hasher.combine(text)
        hasher.combine(foregroundColor)
    }
}

extension SuccessTextProperties {
    /// How the lines of the text line up: the horizontal part of `alignment`.
    var lineAlignment: TextAlignment {
        switch alignment.horizontal {
        case .leading:
            .leading
        case .trailing:
            .trailing
        default:
            .center
        }
    }
}
