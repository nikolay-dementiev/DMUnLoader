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
struct ContentViewDefaultSettings: View {
    
    /**
     The main body of the `ContentViewDefaultSettings` view.
     
     - Returns: A `DMLocalLoadingView` instance configured with:
       - A `DefaultDMLoadingViewProvider` for providing default loading and error views.
       - A `LoadingContentView` as the inner content view.
     
     - Behavior:
       - The `DMLocalLoadingView` manages the loading state and displays the appropriate views
         (loading, error, or success) based on the current state of the `DMLoadingManager`.
       - The `LoadingContentView` serves as the main content displayed when no loading state is active.
     */
    var body: some View {
        DMLocalLoadingView(provider: DefaultDMLoadingViewProvider()) {
            LoadingContentView()
        }
    }
}
