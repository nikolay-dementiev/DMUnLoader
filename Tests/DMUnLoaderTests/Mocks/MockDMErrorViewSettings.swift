//
//  DMUnLoader
//
//  Created by Mykola Dementiev
//

import SwiftUI
@testable import DMUnLoader

struct MockDMErrorViewSettings: DMErrorViewSettings {
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
        frameSize: CustomSizeView(width: 50, height: 50)
    )
}
