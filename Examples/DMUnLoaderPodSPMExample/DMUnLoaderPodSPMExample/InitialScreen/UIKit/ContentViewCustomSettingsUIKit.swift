//
//  DMUnLoaderPodExample
//
//  Created by Mykola Dementiev
//

import UIKit
import DMUnLoader

/**
 A generic `ContentViewCustomSettingsUIKit` class that extends `DMLocalLoadingViewUIKit`
 to provide custom settings and configurations for a loading view in UIKit.
 
 This class is designed to work with a custom `LoadingContentViewUIKit` (`CV`) and a
 `DMLoadingViewProvider` (`LVP`). It ensures that the `innerView` is properly configured
 with the `loadingManager` during initialization.
 
 - Parameters:
   - CV: A type conforming to `LoadingContentViewUIKit`, representing the inner content view.
   - LVP: A type conforming to `DMLoadingViewProviderProtocol`, responsible for providing loading and error views.
 */
final class ContentViewCustomSettingsUIKit<CV: LoadingContentViewUIKit, LVP: DMLoadingViewProviderProtocol>: DMLocalLoadingViewUIKit<CV, LVP> {
    
    /**
     Initializes the `ContentViewCustomSettingsUIKit` instance.
     
     - Parameters:
       - provider: An instance of `LVP` (a `DMLoadingViewProviderProtocol`) that provides custom loading and error views.
       - innerView: An instance of `CV` (a `LoadingContentViewUIKit`) that represents the main content view.
       - manager: A `GlobalLoadingStateManager` instance used to manage the global loading state.
     
     - Behavior:
       - Calls the superclass initializer to set up the `DMLocalLoadingViewUIKit`.
       - Configures the `innerView` by setting its `loadingManager` property to the current `loadingManager`.
     */
    override init(provider: LVP,
                  innerView: CV,
                  manager: GlobalLoadingStateManager) {
        super.init(provider: provider,
                   innerView: innerView,
                   manager: manager)
        
        // Configure the inner view with the loading manager
        innerView.configure(loadingManager: loadingManager)
    }
    
    /**
     Required initializer for decoding from a storyboard or nib file.
     
     - Note: This initializer is not implemented and will always throw a fatal error, as this class
       is not intended to be used with storyboards or nibs.
     
     - Parameter coder: The NSCoder instance used for decoding.
     - Throws: A fatal error indicating that this initializer is not supported.
     */
    @MainActor required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
