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
    
    /// The reference size of the loading view: the view takes at most half of this width and half
    /// of this height, and at least 30 points in each direction, sized to its content within those limits.
    var frameGeometrySize: CGSize { get }
}

/// A concrete implementation of the `DMProgressViewSettings` protocol.
/// This struct provides default settings for a loading view, with customizable properties.
public struct DMProgressViewDefaultSettings: DMProgressViewSettings {
    
    /// Properties related to the loading text displayed in the loading view.
    public let loadingTextProperties: ProgressTextProperties
    
    /// Properties related to the progress indicator displayed in the loading view.
    public let progressIndicatorProperties: ProgressIndicatorProperties
    
    /// The background color of the loading container.
    public let loadingContainerBackgroundColor: Color
    
    /// The reference size of the loading view: the view takes at most half of this width and half
    /// of this height, and at least 30 points in each direction, sized to its content within those limits.
    public let frameGeometrySize: CGSize
    
    /// Initializes a new instance of `DMProgressViewDefaultSettings` with optional customizations.
    /// - Parameters:
    ///   - loadingTextProperties: The properties for the loading text. Defaults to `ProgressTextProperties()`.
    ///   - progressIndicatorProperties: The properties for the progress indicator. Defaults to `ProgressIndicatorProperties()`.
    ///   - loadingContainerBackgroundColor: The background color of the loading container. Defaults to `Color.clear`.
    ///   - frameGeometrySize: The reference size of the loading view: at most half of its width and height. Defaults to `CGSize(width: 300, height: 300)`.
    /// - Example:
    ///   ```swift
    ///   let customSettings = DMProgressViewDefaultSettings(
    ///       loadingTextProperties: ProgressTextProperties(text: "Please wait..."),
    ///       progressIndicatorProperties: ProgressIndicatorProperties(size: .small),
    ///       loadingContainerBackgroundColor: .blue,
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
    
    /// Equal when every setting is equal: the text, the indicator, the background color and
    /// the frame geometry size.
    public static func == (
        lhs: DMProgressViewDefaultSettings,
        rhs: DMProgressViewDefaultSettings
    ) -> Bool {
        lhs.loadingTextProperties == rhs.loadingTextProperties
            && lhs.progressIndicatorProperties == rhs.progressIndicatorProperties
            && lhs.loadingContainerBackgroundColor == rhs.loadingContainerBackgroundColor
            && lhs.frameGeometrySize == rhs.frameGeometrySize
    }

    /// Hashes every setting; the frame geometry size by its width and height.
    public func hash(into hasher: inout Hasher) {
        hasher.combine(loadingTextProperties)
        hasher.combine(progressIndicatorProperties)
        hasher.combine(loadingContainerBackgroundColor)
        hasher.combine(frameGeometrySize.width)
        hasher.combine(frameGeometrySize.height)
    }
}

/// A struct defining properties for the loading text displayed in a loading view.
public struct ProgressTextProperties {
    
    /// The text to display in the loading view.
    public var text: String
    
    /// How the lines of the text line up when it takes more than one line: `.leading`,
    /// `.center` or `.trailing`. A single line is centered in the loading view whatever this
    /// value is.
    public var alignment: TextAlignment
    
    /// The foreground color of the text.
    public var foregroundColor: Color
    
    /// The font used for the text.
    public var font: Font
    
    /// The maximum number of lines the text can occupy.
    public var lineLimit: Int?
    
    /// The padding applied around the text as a whole, once: outside its outermost lines, not around
    /// each line.
    public var linePadding: EdgeInsets
    
    /// Initializes a new instance of `ProgressTextProperties` with optional customizations.
    /// - Parameters:
    ///   - text: The text to display. Defaults to `"Loading..."`.
    ///   - alignment: How the lines of a text of more than one line line up. Defaults to `.center`.
    ///   - foregroundColor: The foreground color of the text. Defaults to `.white`.
    ///   - font: The font used for the text. Defaults to `.body`.
    ///   - lineLimit: The maximum number of lines the text can occupy. Defaults to `3`.
    ///   - linePadding: The padding applied around the text as a whole, not around each line.
    ///   Defaults to `EdgeInsets(top: 0, leading: 10, bottom: 0, trailing: 10)`.
    /// - Example:
    ///   ```swift
    ///   let customTextProperties = ProgressTextProperties(
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
    /// Hashes the properties that `==` compares.
    public func hash(into hasher: inout Hasher) {
        hasher.combine(text)
        hasher.combine(alignment)
        hasher.combine(foregroundColor)
        hasher.combine(font)
        hasher.combine(lineLimit)
        hasher.combine(linePadding.top)
        hasher.combine(linePadding.leading)
        hasher.combine(linePadding.bottom)
        hasher.combine(linePadding.trailing)
    }
}

/// A struct defining properties for the progress indicator displayed in a loading view.
public struct ProgressIndicatorProperties {
    
    /// The size of the progress indicator.
    public let size: ControlSize
    
    /// The tint color of the progress indicator.
    public let tintColor: Color?

    /// The style of the progress indicator. It is always `CircularProgressViewStyle()` and
    /// cannot be changed; for another indicator, return your own view from
    /// `DMLoadingViewProvider.getLoadingView()`.
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
    /// Equal when the size and the tint color are equal. `style` is the same constant in
    /// every value, so it is not compared.
    public static func == (lhs: Self, rhs: Self) -> Bool {
        lhs.size == rhs.size && lhs.tintColor == rhs.tintColor
    }
    
    /// Hashes the size and the tint color, which `==` compares.
    public func hash(into hasher: inout Hasher) {
        hasher.combine(size)
        hasher.combine(tintColor)
    }
}
