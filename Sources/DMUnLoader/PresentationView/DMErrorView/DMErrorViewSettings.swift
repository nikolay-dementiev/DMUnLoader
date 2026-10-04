//
//  DMUnLoader
//
//  Created by Mykola Dementiev
//

import SwiftUI

/// A protocol defining settings for an error view (`DMErrorView`).
/// Conforming types must provide properties for error text, action buttons, text styling, and image settings.
public protocol DMErrorViewSettings {
    
    /// The error message to display in the error view.
    var errorText: String? { get }
    
    /// Settings for the "Close" action button.
    var actionButtonCloseSettings: ActionButtonSettings { get }
    
    /// Settings for the "Retry" action button.
    var actionButtonRetrySettings: ActionButtonSettings { get }
    
    /// Settings for the error text displayed in the error view.
    var errorTextSettings: ErrorTextSettings { get }
    
    /// Settings for the error image displayed in the error view.
    var errorImageSettings: ErrorImageSettings { get }
}

/// A concrete implementation of the `DMErrorViewSettings` protocol.
/// This struct provides default settings for an error view, with customizable properties.
public struct DMErrorDefaultViewSettings: DMErrorViewSettings {
    
    /// The error message to display in the error view.
    public let errorText: String?
    
    /// Settings for the "Close" action button.
    public let actionButtonCloseSettings: ActionButtonSettings
    
    /// Settings for the "Retry" action button.
    public let actionButtonRetrySettings: ActionButtonSettings
    
    /// Settings for the error text displayed in the error view.
    public let errorTextSettings: ErrorTextSettings
    
    /// Settings for the error image displayed in the error view.
    public let errorImageSettings: ErrorImageSettings
    
    /// Creates settings for the error view.
    /// - Parameters:
    ///   - errorText: The title shown above the description of the error. Defaults to
    ///     `"An error has occurred!"`. `nil` shows the description only.
    ///   - actionButtonCloseSettings: Settings for the Close button. Defaults to
    ///     `ActionButtonSettings(text: "Close")`.
    ///   - actionButtonRetrySettings: Settings for the Retry button, shown when the failure
    ///     has a retry action. Defaults to `ActionButtonSettings(text: "Retry")`.
    ///   - errorTextSettings: Settings for both texts. Defaults to `ErrorTextSettings()`.
    ///   - errorImageSettings: Settings for the image. Defaults to the
    ///     `exclamationmark.triangle` symbol.
    /// - Example:
    ///   ```swift
    ///   let customErrorSettings = DMErrorDefaultViewSettings(
    ///       errorText: "Oops! Something went wrong.",
    ///       actionButtonCloseSettings: ActionButtonSettings(text: "Dismiss"),
    ///       actionButtonRetrySettings: ActionButtonSettings(text: "Try Again"),
    ///       errorTextSettings: ErrorTextSettings(foregroundColor: .black, multilineTextAlignment: .leading),
    ///       errorImageSettings: ErrorImageSettings(image: Image(systemName: "xmark.octagon"), foregroundColor: .orange)
    ///   )
    ///   ```
    public init(errorText: String? = "An error has occurred!",
                actionButtonCloseSettings: ActionButtonSettings = ActionButtonSettings(text: "Close"),
                actionButtonRetrySettings: ActionButtonSettings = ActionButtonSettings(text: "Retry"),
                errorTextSettings: ErrorTextSettings = ErrorTextSettings(),
                // swiftlint:disable:next line_length
                errorImageSettings: ErrorImageSettings = ErrorImageSettings(image: Image(systemName: "exclamationmark.triangle"))) {
        
        self.errorText = errorText
        self.actionButtonCloseSettings = actionButtonCloseSettings
        self.actionButtonRetrySettings = actionButtonRetrySettings
        self.errorTextSettings = errorTextSettings
        self.errorImageSettings = errorImageSettings
    }
}

extension DMErrorDefaultViewSettings: Hashable {
    /// Equal when every setting is equal: the error text, both button settings, the text
    /// settings and the image settings, each by its own `==`.
    static public func == (lhs: Self, rhs: Self) -> Bool {
        lhs.errorText == rhs.errorText
            && lhs.actionButtonCloseSettings == rhs.actionButtonCloseSettings
            && lhs.actionButtonRetrySettings == rhs.actionButtonRetrySettings
            && lhs.errorTextSettings == rhs.errorTextSettings
            && lhs.errorImageSettings == rhs.errorImageSettings
    }
    
    /// Hashes the settings that `==` compares.
    public func hash(into hasher: inout Hasher) {
        hasher.combine(errorText)
        hasher.combine(actionButtonCloseSettings)
        hasher.combine(actionButtonRetrySettings)
        hasher.combine(errorTextSettings)
        hasher.combine(errorImageSettings)
    }
}

/// A struct defining settings for an action button in an error view.
public struct ActionButtonSettings: Identifiable {
    
    /// Identifies the settings. Two settings are equal when their `id` and text are equal, so
    /// give settings with another style another `id`.
    public let id: UUID
    
    /// The text displayed on the button.
    public let text: String
    
    /// Makes the style of the button. Called on the main actor each time the button is drawn.
    public let styleFactory: @MainActor () -> AnyButtonStyle

    /// Creates the settings of a button with a style of your own.
    /// - Parameters:
    ///   - id: Identifies the settings. Defaults to a new `UUID`.
    ///   - text: The text of the button.
    ///   - styleFactory: Makes the style of the button, on the main actor.
    public init(
        id: UUID = UUID(),
        text: String,
        styleFactory: @escaping @MainActor () -> AnyButtonStyle
    ) {
        self.id = id
        self.text = text
        self.styleFactory = styleFactory
    }
    
    /// Creates the settings of a button with the style of the HUD: white text in a white capsule,
    /// which in the HUD shrinks a little while pressed, unless Reduce Motion is on.
    /// - Parameters:
    ///   - id: Identifies the settings. Defaults to a new `UUID`.
    ///   - text: The text of the button.
    public init(
        id: UUID = UUID(),
        text: String
    ) {
        self.init(
            id: id,
            text: text,
            styleFactory: { @MainActor in
                AnyButtonStyle(.hudButtonStyle)
            }
        )
    }
}

extension ActionButtonSettings: Hashable {
    /// Equal when the `id` and the text are equal. The style factory is a closure and cannot
    /// be compared: the `id` stands for it, so give settings with another style another `id`.
    static public func == (lhs: Self, rhs: Self) -> Bool {
        lhs.id == rhs.id && lhs.text == rhs.text
    }

    /// Hashes the `id` and the text.
    public func hash(into hasher: inout Hasher) {
        hasher.combine(id)
        hasher.combine(text)
    }
}

/// A button style that wraps another one, so that button settings can hold any style.
public struct AnyButtonStyle: ButtonStyle {
    private let _makeBody: (Configuration) -> AnyView

    /// Wraps `style`.
    public init<S: ButtonStyle>(_ style: S) {
        self._makeBody = { configuration in
            AnyView(style.makeBody(configuration: configuration))
        }
    }

    /// The body that the wrapped style makes for `configuration`.
    public func makeBody(configuration: Configuration) -> some View {
        _makeBody(configuration)
    }
}

/// A struct defining settings for the error text displayed in an error view.
public struct ErrorTextSettings {
    
    /// The foreground color of the error text.
    let foregroundColor: Color?
    
    /// The alignment of the error text.
    let multilineTextAlignment: TextAlignment
    
    /// The padding applied around the error text.
    let padding: EdgeInsets
    
    /// Initializes a new instance of `ErrorTextSettings` with optional customizations.
    /// - Parameters:
    ///   - foregroundColor: The foreground color of the error text. Defaults to `.white`.
    ///   - multilineTextAlignment: The alignment of the error text. Defaults to `.center`.
    ///   - padding: The padding applied around the error text. Defaults
    ///   to `EdgeInsets(top: 0, leading: 10, bottom: 0, trailing: 10)`.
    /// - Example:
    ///   ```swift
    ///   let errorTextSettings = ErrorTextSettings(
    ///       foregroundColor: .black,
    ///       multilineTextAlignment: .leading,
    ///       padding: EdgeInsets(top: 5, leading: 15, bottom: 5, trailing: 15)
    ///   )
    ///   ```
    public init(foregroundColor: Color? = .white,
                multilineTextAlignment: TextAlignment = .center,
                padding: EdgeInsets = EdgeInsets(top: 0, leading: 10, bottom: 0, trailing: 10)) {
        self.foregroundColor = foregroundColor
        self.multilineTextAlignment = multilineTextAlignment
        self.padding = padding
    }
}

extension ErrorTextSettings: Hashable {
    /// Hashes the settings that `==` compares: the colour, the alignment and the padding.
    public func hash(into hasher: inout Hasher) {
        hasher.combine(foregroundColor)
        hasher.combine(multilineTextAlignment)
        hasher.combine(padding.top)
        hasher.combine(padding.leading)
        hasher.combine(padding.bottom)
        hasher.combine(padding.trailing)
    }
}

/// A struct defining settings for the error image displayed in an error view.
///
/// The image of the default error settings, the exclamation mark triangle, is hidden from
/// assistive technology: the texts of the error view name the failure. An image equal to it
/// counts as that default; any other image keeps the accessibility it was given.
public struct ErrorImageSettings {
    
    /// The image to display as the error icon.
    let image: Image
    
    /// The foreground color of the image.
    let foregroundColor: Color?
    
    /// The size of the image frame.
    let frameSize: CustomViewSize
    
    /// Initializes a new instance of `ErrorImageSettings` with optional customizations.
    /// - Parameters:
    ///   - image: The image to display. Defaults to an exclamation mark triangle icon.
    ///   - foregroundColor: The foreground color of the image. Defaults to `.red`.
    ///   - frameSize: The size of the image frame. Defaults to `CustomSizeView(width: 50, height: 50)`.
    /// - Example:
    ///   ```swift
    ///   let errorImageSettings = ErrorImageSettings(
    ///       image: Image(systemName: "xmark.octagon"),
    ///       foregroundColor: .orange,
    ///       frameSize: CustomSizeView(width: 60, height: 60)
    ///   )
    ///   ```
    public init(image: Image,
                foregroundColor: Color? = .red,
                frameSize: CustomViewSize = CustomViewSize(width: 50, height: 50)) {
        self.image = image
        self.foregroundColor = foregroundColor
        self.frameSize = frameSize
    }
}

extension ErrorImageSettings: Hashable {
    /// Equal when the image, the foreground color and the frame size are equal.
    public static func == (lhs: Self, rhs: Self) -> Bool {
        lhs.image == rhs.image
            && lhs.foregroundColor == rhs.foregroundColor
            && lhs.frameSize == rhs.frameSize
    }

    /// Hashes the foreground color and the frame size. `Image` is not `Hashable`.
    public func hash(into hasher: inout Hasher) {
        hasher.combine(foregroundColor)
        hasher.combine(frameSize)
    }
}

extension ErrorImageSettings {
    /// Whether the image is the one of the default error settings, which only decorates.
    var showsTheDefaultImage: Bool {
        image == Image(systemName: "exclamationmark.triangle")
    }
}
