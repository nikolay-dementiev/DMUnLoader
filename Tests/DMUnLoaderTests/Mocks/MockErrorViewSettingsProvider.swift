//
//  DMUnLoader
//
//  Created by Mykola Dementiev
//

import SwiftUI
@testable import DMUnLoader

struct MockErrorViewSettingsProvider: DMErrorViewSettings {
    var errorImageSettings: ErrorImageSettings = .init(
        image: Image(systemName: "xmark.circle"),
        foregroundColor: .red,
        frameSize: CustomSizeView(width: 50,
                                  height: 50,
                                  alignment: .top)
    )
    
    var errorTextSettings: ErrorTextSettings = .init(
        foregroundColor: .black,
        multilineTextAlignment: .center,
        padding: EdgeInsets(top: 10,
                            leading: 10,
                            bottom: 10,
                            trailing: 10)
    )
    
    var actionButtonCloseSettings = ActionButtonSettings(text: "Close")
    
    var actionButtonRetrySettings = ActionButtonSettings(text: "Retry")
    
    var errorText: String? = "An error occurred"
}
