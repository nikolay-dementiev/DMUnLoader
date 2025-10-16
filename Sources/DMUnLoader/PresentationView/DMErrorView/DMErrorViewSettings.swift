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
    
    /// Initializes a new instance of `DMErrorDefaultViewSettings` with optional customizations.
    /// - Parameters:
    ///   - errorText: The error message to display. Defaults to `"An error has occurred!"`.
    ///   - actionButtonCloseSettings: Settings for the "Close" button. Defaults to `ActionButtonSettings(text: "Close")`.
    ///   - actionButtonRetrySettings: Settings for the "Retry" button. Defaults to `ActionButtonSettings(text: "Retry")`.
    ///   - errorTextSettings: Settings for the error text. Defaults to `ErrorTextSettings()`.
    ///   - errorImageSettings: Settings for the error image. Defaults to an exclamation mark triangle icon.
    /// - Example:
    ///   ```swift
    ///   let customErrorSettings = DMErrorDefaultViewSettings(
    ///       errorText: "Oops! Something went wrong.",
    ///       actionButtonCloseSettings: ActionButtonSettings(text: "Dismiss", backgroundColor: .red),
    ///       actionButtonRetrySettings: ActionButtonSettings(text: "Try Again", backgroundColor: .blue),
    ///       errorTextSettings: ErrorTextSettings(foregroundColor: .black, multilineTextAlignment: .leading),
    ///       errorImageSettings: ErrorImageSettings(image: Image(systemName: "xmark.octagon"), foregroundColor: .orange)
    ///   )
    ///   ```
    public init(errorText: String? = "An error has occured!",
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

/// A struct defining settings for an action button in an error view.
public struct ActionButtonSettings {
    
    /// The text displayed on the button.
    public let text: String
    
    public let style: AnyButtonStyle
    
    public init(text: String,
                style: (any ButtonStyle)? = nil) {
        self.text = text
        if let style = style {
            self.style = AnyButtonStyle(style)
        } else {
            self.style = AnyButtonStyle(.hudButtonStyle)
        }
    }
}

public struct AnyButtonStyle: ButtonStyle {
    private let _makeBody: (Configuration) -> AnyView

    public init<S: ButtonStyle>(_ style: S) {
        self._makeBody = { configuration in
            AnyView(style.makeBody(configuration: configuration))
        }
    }

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

/// A struct defining settings for the error image displayed in an error view.
public struct ErrorImageSettings {
    
    /// The image to display as the error icon.
    let image: Image
    
    /// The foreground color of the image.
    let foregroundColor: Color?
    
    /// The size of the image frame.
    let frameSize: CustomSizeView
    
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
                frameSize: CustomSizeView = CustomSizeView(width: 50, height: 50)) {
        self.image = image
        self.foregroundColor = foregroundColor
        self.frameSize = frameSize
    }
}
