//
//  DMErrorHandling
//
//  Created by Mykola Dementiev
//

import SwiftUI
import UIKit

/// A `UIView` subclass that integrates a local loading state management system with a UIKit view.
/// This class bridges SwiftUI's `DMLocalLoadingView` with UIKit views using `DMWrappedViewUIKit`.
open class DMLocalLoadingViewUIKit<UIKitView: UIView,
                                   Provider: DMLoadingViewProviderProtocol>: UIView {
    
    /// A type alias for the SwiftUI-hosted content (`DMLocalLoadingView`) that wraps a UIKit view.
    private typealias HostingContent = DMLocalLoadingView<DMWrappedViewUIKit<UIKitView>, Provider>
    
    /// The hosting controller responsible for embedding the SwiftUI view into the UIKit hierarchy.
    private let hostingController: UIHostingController<AnyView>
    
    /// A weak reference to the local loading manager used for managing the loading state.
    public weak private(set) var loadingManager: DMLoadingManager?
    
    /// Initializes a new instance of `DMLocalLoadingViewUIKit`.
    /// - Parameters:
    ///   - provider: The provider responsible for supplying views and settings for loading, error, and success states.
    ///   - innerView: The UIKit view to be embedded as the content of the SwiftUI view.
    ///   - manager: The global loading state manager to integrate with the local loading view.
    /// - Example:
    ///   ```swift
    ///   let customView = UILabel()
    ///   customView.text = "Hello from UIKit!"
    ///
    ///   let provider = DefaultDMLoadingViewProvider()
    ///   let globalManager = GlobalLoadingStateManager()
    ///
    ///   let localLoadingView = DMLocalLoadingViewUIKit(provider: provider,
    ///                                                 innerView: customView,
    ///                                                   manager: globalManager)
    ///   ```
    public init(provider: Provider,
                innerView: UIKitView,
                manager: GlobalLoadingStateManager) {
        // Create the SwiftUI view and wrap it in an `AnyView`
        let swiftUIView = Self.makeSwiftUIView(provider: provider, view: innerView)
        self.loadingManager = swiftUIView.getLoadingManager()
        
        // Initialize the hosting controller with the SwiftUI view
        hostingController = UIHostingController(rootView:
            AnyView(swiftUIView
                .environment(\.globalLoadingManager, manager)
            ))
        
        super.init(frame: .zero)
        
        // Update the loading manager reference
        self.loadingManager = swiftUIView.getLoadingManager()
        
        // Set up the UI
        setupUI()
    }
    
    /// Required initializer for decoding from a storyboard or nib file.
    /// - Parameter coder: The decoder object.
    /// - Note: This initializer is not implemented and will return `nil`.
    required public init?(coder: NSCoder) {
        print("init(coder:) has not been implemented")
        return nil
    }
    
    /// Sets up the UI by adding the hosting controller's view as a subview and applying constraints.
    private func setupUI() {
        guard let view = hostingController.view else { return }
        
        view.translatesAutoresizingMaskIntoConstraints = false
        addSubview(view)
        
        NSLayoutConstraint.activate([
            view.topAnchor.constraint(equalTo: topAnchor),
            view.bottomAnchor.constraint(equalTo: bottomAnchor),
            view.leadingAnchor.constraint(equalTo: leadingAnchor),
            view.trailingAnchor.constraint(equalTo: trailingAnchor)
        ])
    }
    
    /// Creates a SwiftUI view (`DMLocalLoadingView`) that wraps the provided UIKit view.
    /// - Parameters:
    ///   - provider: The provider responsible for supplying views and settings for loading, error, and success states.
    ///   - view: The UIKit view to be embedded as the content of the SwiftUI view.
    /// - Returns: A `DMLocalLoadingView` instance configured with the provided parameters.
    private static func makeSwiftUIView(provider: Provider, view: UIKitView) -> HostingContent {
        let newView = DMLocalLoadingView(provider: provider) {
            DMWrappedViewUIKit(uiView: view)
        }
        
        return newView
    }
}
