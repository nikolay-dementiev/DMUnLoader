//
//  DMUnLoader
//
//  Created by Mykola Dementiev
//

import SwiftUI
@testable import DMUnLoader

struct StubDMErrorViewSettings: DMErrorViewSettings {
    var errorText: String? = "Mock Error Occurred"
    
    var actionButtonCloseSettings = ActionButtonSettings(text: "Close")
    
    var actionButtonRetrySettings = ActionButtonSettings(text: "Retry")
    
    var errorTextSettings: ErrorTextSettings = ErrorTextSettings(
        foregroundColor: .white,
        multilineTextAlignment: .center,
        padding: EdgeInsets(top: 0, leading: 10, bottom: 0, trailing: 10)
    )
    
    var errorImageSettings: ErrorImageSettings = ErrorImageSettings(
        image: Image(systemName: "exclamationmark.circle.fill"),
        foregroundColor: .red,
        frameSize: CustomViewSize(width: 50, height: 50)
    )
}

extension StubDMErrorViewSettings: Hashable {
    static func == (lhs: Self, rhs: Self) -> Bool {
        lhs.errorText == rhs.errorText
            && lhs.actionButtonCloseSettings == rhs.actionButtonCloseSettings
            && lhs.actionButtonRetrySettings == rhs.actionButtonRetrySettings
            && lhs.errorTextSettings == rhs.errorTextSettings
            && lhs.errorImageSettings == rhs.errorImageSettings
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(errorText)
        hasher.combine(actionButtonCloseSettings)
        hasher.combine(actionButtonRetrySettings)
        hasher.combine(errorTextSettings)
        hasher.combine(errorImageSettings)
    }
}
