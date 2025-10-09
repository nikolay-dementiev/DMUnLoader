//
//  DMUnLoaderPodExample
//
//  Created by Mykola Dementiev
//

import SwiftUI
import DMUnLoader

/**
 A SwiftUI view (`ContentViewDefaultSettings`) that represents a loading view with default settings.
 
 This view uses `DMLocalLoadingView` to wrap a `LoadingContentView` and provides a default
 implementation of `DMLoadingViewProviderProtocol` for managing loading states, error views, and success views.
 */
struct ContentViewDefaultSettingsTopViewSwiftUI<LM: DMLoadingManagerProtocol>: View {
    
    var loadingManager: LM
    
    var body: some View {
        LoadingContentViewSwiftUI(
            loadingManager: loadingManager,
            provider: DefaultDMLoadingViewProvider()
        )
    }
}
