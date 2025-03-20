//
//  DMErrorHandling
//
//  Created by Mykola Dementiev
//

import SwiftUICore

/// A protocol defining settings for a loading view (`DMProgressView`).
/// Conforming types must provide properties for text, progress indicator, container appearance, and geometry.
public protocol DMLoadingViewSettings {
    
    /// Properties related to the loading text displayed in the loading view.
    var loadingTextProperties: LoadingTextProperties { get }
    
    /// Properties related to the progress indicator displayed in the loading view.
    var progressIndicatorProperties: ProgressIndicatorProperties { get }
    
    /// The foreground color of the loading container.
    var loadingContainerForegroundColor: Color { get }
    
    /// The size of the frame geometry for the loading view.
    var frameGeometrySize: CGSize { get }
}

/// A concrete implementation of the `DMLoadingViewSettings` protocol.
/// This struct provides default settings for a loading view, with customizable properties.
public struct DMLoadingDefaultViewSettings: DMLoadingViewSettings {
    
    /// Properties related to the loading text displayed in the loading view.
    public let loadingTextProperties: LoadingTextProperties
    
    /// Properties related to the progress indicator displayed in the loading view.
    public let progressIndicatorProperties: ProgressIndicatorProperties
    
    /// The foreground color of the loading container.
    public let loadingContainerForegroundColor: Color
    
    /// The size of the frame geometry for the loading view.
    public let frameGeometrySize: CGSize
    
    /// Initializes a new instance of `DMLoadingDefaultViewSettings` with optional customizations.
    /// - Parameters:
    ///   - loadingTextProperties: The properties for the loading text. Defaults to `LoadingTextProperties()`.
    ///   - progressIndicatorProperties: The properties for the progress indicator. Defaults to `ProgressIndicatorProperties()`.
    ///   - loadingContainerForegroundColor: The foreground color of the loading container. Defaults to `Color.primary`.
    ///   - frameGeometrySize: The size of the frame geometry. Defaults to `CGSize(width: 300, height: 300)`.
    /// - Example:
    ///   ```swift
    ///   let customSettings = DMLoadingDefaultViewSettings(
    ///       loadingTextProperties: LoadingTextProperties(text: "Please wait..."),
    ///       progressIndicatorProperties: ProgressIndicatorProperties(size: .small),
    ///       loadingContainerForegroundColor: .blue,
    ///       frameGeometrySize: CGSize(width: 400, height: 400)
    ///   )
    ///   ```
    public init(loadingTextProperties: LoadingTextProperties = LoadingTextProperties(),
                progressIndicatorProperties: ProgressIndicatorProperties = ProgressIndicatorProperties(),
                loadingContainerForegroundColor: Color = Color.primary,
                frameGeometrySize: CGSize = CGSize(width: 300, height: 300)) {
        
        self.loadingTextProperties = loadingTextProperties
        self.progressIndicatorProperties = progressIndicatorProperties
        self.loadingContainerForegroundColor = loadingContainerForegroundColor
        self.frameGeometrySize = frameGeometrySize
    }
}

/// A struct defining properties for the loading text displayed in a loading view.
public struct LoadingTextProperties {
    
    /// The text to display in the loading view.
    public var text: String
    
    /// The alignment of the text within the loading view.
    public var alignment: TextAlignment
    
    /// The foreground color of the text.
    public var foregroundColor: Color
    
    /// The font used for the text.
    public var font: Font
    
    /// The maximum number of lines the text can occupy.
    public var lineLimit: Int?
    
    /// The padding applied around each line of text.
    public var linePadding: EdgeInsets
    
    /// Initializes a new instance of `LoadingTextProperties` with optional customizations.
    /// - Parameters:
    ///   - text: The text to display. Defaults to `"Loading..."`.
    ///   - alignment: The alignment of the text. Defaults to `.center`.
    ///   - foregroundColor: The foreground color of the text. Defaults to `.white`.
    ///   - font: The font used for the text. Defaults to `.body`.
    ///   - lineLimit: The maximum number of lines the text can occupy. Defaults to `3`.
    ///   - linePadding: The padding applied around each line of text.
    ///   Defaults to `EdgeInsets(top: 0, leading: 10, bottom: 0, trailing: 10)`.
    /// - Example:
    ///   ```swift
    ///   let customTextProperties = LoadingTextProperties(
    ///       text: "Processing...",
    ///       alignment: .leading,
    ///       foregroundColor: .black,
    ///       font: .headline,
    ///       lineLimit: 2,
    ///       linePadding: EdgeInsets(top: 5, leading: 15, bottom: 5, trailing: 15)
    ///   )
    ///   ```
    public init(
        text: String = "Loading...",
        alignment: TextAlignment = .center,
        foregroundColor: Color = .white,
        font: Font = .body,
        lineLimit: Int? = 3,
        linePadding: EdgeInsets = EdgeInsets(top: 0, leading: 10, bottom: 0, trailing: 10)
    ) {
        self.text = text
        self.alignment = alignment
        self.foregroundColor = foregroundColor
        self.font = font
        self.lineLimit = lineLimit
        self.linePadding = linePadding
    }
}

/// A struct defining properties for the progress indicator displayed in a loading view.
public struct ProgressIndicatorProperties {
    
    /// The size of the progress indicator.
    public var size: ControlSize
    
    /// The tint color of the progress indicator.
    public var tintColor: Color?
    
    /// Initializes a new instance of `ProgressIndicatorProperties` with optional customizations.
    /// - Parameters:
    ///   - size: The size of the progress indicator. Defaults to `.large`.
    ///   - tintColor: The tint color of the progress indicator. Defaults to `.white`.
    /// - Example:
    ///   ```swift
    ///   let customProgressProperties = ProgressIndicatorProperties(
    ///       size: .small,
    ///       tintColor: .green
    ///   )
    ///   ```
    public init(
        size: ControlSize = .large,
        tintColor: Color? = .white
    ) {
        self.size = size
        self.tintColor = tintColor
    }
}
