//
//  DMErrorHandling
//
//  Created by Mykola Dementiev
//

import SwiftUICore

// This protocol responsible to provide settings for `DMSuccessView`
public protocol DMSuccessViewSettings {
    var successImageProperties: SuccessImageProperties { get }
    var successTextProperties: SuccessTextProperties { get }
}

/// Default `Success` settings implementation
public struct DMSuccessDefaultViewSettings: DMSuccessViewSettings {
    public let successImageProperties: SuccessImageProperties
    public let successTextProperties: SuccessTextProperties
    
    public init(successImageProperties: SuccessImageProperties = SuccessImageProperties(),
                successTextProperties: SuccessTextProperties = SuccessTextProperties()) {
        
        self.successImageProperties = successImageProperties
        self.successTextProperties = successTextProperties
    }
}

public struct SuccessImageProperties {
    public var image: Image
    public var frame: CustomSizeView
    public var foregroundColor: Color?
    
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

public struct SuccessTextProperties {
    public var text: String?
    public var foregroundColor: Color?
    
    public init(
        text: String? = "Success!",
        foregroundColor: Color? = .white
    ) {
        self.text = text
        self.foregroundColor = foregroundColor
    }
}
