//
//  DMErrorHandling
//
//  Created by Mykola Dementiev
//
import SwiftUICore

// This protocol responsible to provide settings for `DMProgressView`
public protocol DMLoadingViewSettings {
    var loadingTextProperties: LoadingTextProperties { get }
    var progressIndicatorProperties: ProgressIndicatorProperties { get }
    var loadingContainerForegroundColor: Color { get }
    var frameGeometrySize: CGSize { get }
}

/// Default `Loading` settings implementation
public struct DMLoadingDefaultViewSettings: DMLoadingViewSettings {
    public let loadingTextProperties: LoadingTextProperties
    public let progressIndicatorProperties: ProgressIndicatorProperties
    public let loadingContainerForegroundColor: Color
    public let frameGeometrySize: CGSize

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

public struct LoadingTextProperties {
    public var text: String
    public var alignment: TextAlignment
    public var foregroundColor: Color
    public var font: Font
    public var lineLimit: Int?
    public var linePadding: EdgeInsets
    
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

public struct ProgressIndicatorProperties {
    public var size: ControlSize
    public var tintColor: Color?
    
    public init(
        size: ControlSize = .large,
        tintColor: Color? = .white
    ) {
        self.size = size
        self.tintColor = tintColor
    }
}
