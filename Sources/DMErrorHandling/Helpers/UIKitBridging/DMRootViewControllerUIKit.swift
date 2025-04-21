//
//  DMErrorHandlingPodExample
//
//  Created by Mykola Dementiev
//

import UIKit
import SwiftUI

/// A `UIViewController` subclass that integrates a SwiftUI-based root loading view with UIKit content.
/// This class allows UIKit views to be embedded into a SwiftUI hierarchy using `DMRootLoadingView` and `DMWrappedViewUIKit`.
public final class DMRootViewControllerUIKit<ContentView: UIView>: UIViewController {
    
    /// The hosting controller responsible for embedding the SwiftUI root view (`DMRootLoadingView`) into the UIKit hierarchy.
    private var hostingController: UIHostingController<DMRootLoadingView<DMWrappedViewUIKit<ContentView>>>?
    
    /// The root content view managed by this view controller.
    /// - Note: This view combines a SwiftUI `DMRootLoadingView` with a UIKit `ContentView` wrapped using `DMWrappedViewUIKit`.
    private(set) internal var rootContentView: DMRootLoadingView<DMWrappedViewUIKit<ContentView>>
    
    /// A computed property that provides access to the global loading manager used by the root content view.
    /// - Returns: A closure that retrieves the `GlobalLoadingStateManager` instance associated with the root content view.
    public var getLoadingManager: () -> GlobalLoadingStateManager {
        rootContentView.getLoadingManager
    }
    
    /// Initializes a new instance of `DMRootViewControllerUIKit` with a pre-configured root content view.
    /// - Parameter rootContentView: The root content view to display,
    /// combining a SwiftUI `DMRootLoadingView` with a UIKit `ContentView`.
    public init(rootContentView: DMRootLoadingView<DMWrappedViewUIKit<ContentView>>) {
        self.rootContentView = rootContentView
        
        super.init(nibName: nil, bundle: nil)
    }
    
    /// Convenience initializer that creates a default root content view with a UIKit `ContentView`.
    /// - Parameter contentView: The UIKit view to embed as the content of the root SwiftUI view. Defaults to an empty `UIView`.
    public convenience init(contentView: ContentView = UIView()) {
        // Creating a SwiftUI view
        let rootContentView = DMRootLoadingView { _ in
            // Using UIKit Views as Content for Root SwiftUI Views
            DMWrappedViewUIKit(uiView: contentView)
        }
        
        self.init(rootContentView: rootContentView)
    }
    
    /// Required initializer for decoding from a storyboard or nib file.
    /// - Parameter coder: The decoder object.
    /// - Note: This initializer is not implemented and will return `nil`.
    required init?(coder: NSCoder) {
        print("init(coder:) has not been implemented")
        return nil
    }
    
    /// Called after the view controller's view is loaded into memory.
    /// - Behavior:
    ///   - Embeds the SwiftUI root view (`DMRootLoadingView`) into the UIKit hierarchy
    ///   using a `UIHostingController`.
    ///   - Configures the hosting controller's view to match the parent view's bounds
    ///   and resizing behavior.
    public override func viewDidLoad() {
        super.viewDidLoad()
        
        // Creating UIHostingController
        let hostingController = UIHostingController(rootView: rootContentView)
        self.hostingController = hostingController
        
        // Add as a child controller
        hostingController.willMove(toParent: self)
        addChild(hostingController)
        hostingController.view.frame = view.bounds
        hostingController.view.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        view.addSubview(hostingController.view)
        hostingController.didMove(toParent: self)
    }
}
