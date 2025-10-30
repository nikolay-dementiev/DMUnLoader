//
//  DMUnLoader
//
//  Created by Mykola Dementiev
//

import SwiftUI

/// A protocol defining settings for a loading view (`DMProgressView`).
/// Conforming types must provide properties for text, progress indicator, container appearance, and geometry.
public protocol DMProgressViewSettings {
    
    /// Properties related to the loading text displayed in the loading view.
    var loadingTextProperties: ProgressTextProperties { get }
    
    /// Properties related to the progress indicator displayed in the loading view.
    var progressIndicatorProperties: ProgressIndicatorProperties { get }
    
    /// The background color of the loading container.
    var loadingContainerBackgroundColor: Color { get }
    
    /// The size of the frame geometry for the loading view.
    var frameGeometrySize: CGSize { get }
}

/// A concrete implementation of the `DMLoadingViewSettings` protocol.
/// This struct provides default settings for a loading view, with customizable properties.
public struct DMProgressViewDefaultSettings: DMProgressViewSettings {
    
    /// Properties related to the loading text displayed in the loading view.
    public let loadingTextProperties: ProgressTextProperties
    
    /// Properties related to the progress indicator displayed in the loading view.
    public let progressIndicatorProperties: ProgressIndicatorProperties
    
    /// The foreground color of the loading container.
    public let loadingContainerBackgroundColor: Color
    
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
    public init(loadingTextProperties: ProgressTextProperties = ProgressTextProperties(),
                progressIndicatorProperties: ProgressIndicatorProperties = ProgressIndicatorProperties(),
                loadingContainerBackgroundColor: Color = Color.clear,
                frameGeometrySize: CGSize = CGSize(width: 300, height: 300)) {
        
        self.loadingTextProperties = loadingTextProperties
        self.progressIndicatorProperties = progressIndicatorProperties
        self.loadingContainerBackgroundColor = loadingContainerBackgroundColor
        self.frameGeometrySize = frameGeometrySize
    }
}

extension DMProgressViewDefaultSettings: Hashable {
    
    public static func == (
        lhs: DMProgressViewDefaultSettings,
        rhs: DMProgressViewDefaultSettings
    ) -> Bool {
        lhs.hashValue == rhs.hashValue
    }
    
    public func hash(into hasher: inout Hasher) {
        hasher.combine(loadingTextProperties)
        hasher.combine(progressIndicatorProperties)
        hasher.combine(loadingContainerBackgroundColor)
        hasher.combine(frameGeometrySize)
    }
}

/// A struct defining properties for the loading text displayed in a loading view.
public struct ProgressTextProperties {
    
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

extension ProgressTextProperties: Hashable {
    public func hash(into hasher: inout Hasher) {
        hasher.combine(text)
        hasher.combine(alignment)
        hasher.combine(foregroundColor)
        hasher.combine(font)
        hasher.combine(lineLimit)
        hasher.combine(linePadding)
    }
}

/// A struct defining properties for the progress indicator displayed in a loading view.
public struct ProgressIndicatorProperties {
    
    /// The size of the progress indicator.
    public let size: ControlSize
    
    /// The tint color of the progress indicator.
    public let tintColor: Color?
    
    public let style = CircularProgressViewStyle()
    
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

extension ProgressIndicatorProperties: Hashable {
    public static func == (lhs: Self, rhs: Self) -> Bool {
        lhs.hashValue == rhs.hashValue
    }
    
    public func hash(into hasher: inout Hasher) {
        hasher.combine(size)
        hasher.combine(tintColor)
    }
}
