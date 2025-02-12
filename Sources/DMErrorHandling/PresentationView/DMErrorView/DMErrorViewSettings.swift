//
//  DMErrorViewSettings.swift
//  DMErrorHandling
//
//  Created by Nikolay Dementiev on 03.02.2025.
//

import SwiftUICore

// This protocol responsible to provide view settings for `DMErrorView`
public protocol DMErrorViewSettings {
    var errorText: String? { get }
    var actionButtonCloseSettings: ActionButtonSettings { get }
    var actionButtonRetrySettings: ActionButtonSettings { get }
    var errorTextSettings: ErrorTextSettings { get }
    var errorImageSettings: ErrorImageSettings { get }
}

///Default `Error` settings implementation
public struct DMErrorDefaultViewSettings: DMErrorViewSettings {
    public let errorText: String?
    public let actionButtonCloseSettings: ActionButtonSettings
    public let actionButtonRetrySettings: ActionButtonSettings
    public let errorTextSettings: ErrorTextSettings
    public let errorImageSettings: ErrorImageSettings
    
    public init(errorText: String? = "An error has occured!",
                actionButtonCloseSettings: ActionButtonSettings = ActionButtonSettings(text: "Close"),
                actionButtonRetrySettings: ActionButtonSettings = ActionButtonSettings(text: "Retry"),
                errorTextSettings: ErrorTextSettings = ErrorTextSettings(),
                errorImageSettings: ErrorImageSettings = ErrorImageSettings(image: Image(systemName: "exclamationmark.triangle"))) {
        
        self.errorText = errorText
        self.actionButtonCloseSettings = actionButtonCloseSettings
        self.actionButtonRetrySettings = actionButtonRetrySettings
        self.errorTextSettings = errorTextSettings
        self.errorImageSettings = errorImageSettings
    }
}

public struct ActionButtonSettings {
    public let text: String
    public let backgroundColor: Color
    public let cornerRadius: CGFloat
    
    public init(text: String,
                backgroundColor: Color = .white,
                cornerRadius: CGFloat = 8) {
        self.text = text
        self.backgroundColor = backgroundColor
        self.cornerRadius = cornerRadius
    }
}

public struct ErrorTextSettings {
    let foregroundColor: Color?
    let multilineTextAlignment: TextAlignment
    let padding: EdgeInsets
    
    public init(foregroundColor: Color? = .white,
                multilineTextAlignment: TextAlignment = .center,
                padding: EdgeInsets = EdgeInsets(top: 0, leading: 10, bottom: 0, trailing: 10)) {
        self.foregroundColor = foregroundColor
        self.multilineTextAlignment = multilineTextAlignment
        self.padding = padding
    }
}

public struct ErrorImageSettings {
    let image: Image
    let foregroundColor: Color?
    let frameSize: CustomSizeView
    
    public init(image: Image,
                foregroundColor: Color? = .red,
                frameSize: CustomSizeView = CustomSizeView(width: 50, height: 50)) {
        self.image = image
        self.foregroundColor = foregroundColor
        self.frameSize = frameSize
        
    }
}
