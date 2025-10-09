//
//  DMUnLoaderPodExample
//
//  Created by Mykola Dementiev
//

import SwiftUI
import DMUnLoader

/**
 A SwiftUI view (`ContentViewCustomSettings`) that represents a loading view with custom settings.
 
 This view uses `DMLocalLoadingView` to wrap a `LoadingContentView` and provides a custom
 implementation of `DMLoadingViewProviderProtocol` for managing loading states, error views, and success views.
 */
struct ContentViewCustomSettingsTopViewSwiftUI<LM: DMLoadingManagerProtocol>: View {
    
    var loadingManager: LM
    
    var body: some View {
        LoadingContentViewSwiftUI(
            loadingManager: loadingManager,
            provider: CustomDMLoadingViewProvider()
        )
    }
}
