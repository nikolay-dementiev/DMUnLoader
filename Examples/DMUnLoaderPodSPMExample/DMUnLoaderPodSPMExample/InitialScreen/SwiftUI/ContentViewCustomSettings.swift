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
struct ContentViewCustomSettings: View {
    
    /**
     The main body of the `ContentViewCustomSettings` view.
     
     - Returns: A `DMLocalLoadingView` instance configured with:
       - A `CustomDMLoadingViewProvider` for providing custom loading and error views.
       - A `LoadingContentView` as the inner content view.
     
     - Behavior:
       - The `DMLocalLoadingView` manages the loading state and displays the appropriate views
         (loading, error, or success) based on the current state of the `DMLoadingManager`.
       - The `CustomDMLoadingViewProvider` allows for customization of the appearance and behavior
         of the loading and error views.
       - The `LoadingContentView` serves as the main content displayed when no loading state is active.
     */
    var body: some View {
        DMLocalLoadingView(provider: CustomDMLoadingViewProvider()) {
            LoadingContentView()
        }
    }
}
