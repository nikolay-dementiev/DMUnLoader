//
//  DMErrorHandlingPodExample
//
//  Created by Mykola Dementiev
//

import UIKit
import SwiftUI

public final class DMRootViewControllerUIKit<ContentView: UIView>: UIViewController {
    
    private var hostingController: UIHostingController<DMRootLoadingView<DMWrappedViewUIKit<ContentView>>>?
    private(set) internal var rootContentView: DMRootLoadingView<DMWrappedViewUIKit<ContentView>>
    
    // Making custom `binding` to obtain the Loading Manager object
    public var getLoadingManager: () -> GlobalLoadingStateManager {
        rootContentView.getLoadingManager
    }
    
    public init(rootContentView: DMRootLoadingView<DMWrappedViewUIKit<ContentView>>) {
        self.rootContentView = rootContentView
        
        super.init(nibName: nil, bundle: nil)
    }
    
    public convenience init(contentView: ContentView = UIView()) {
        // Creating a SwiftUI view
        let rootContentView = DMRootLoadingView { _ in
            // Using UIKit Views as Content for Root SwiftUI Views
            DMWrappedViewUIKit(uiView: contentView)
        }
        
        self.init(rootContentView: rootContentView)
    }
    
    required init?(coder: NSCoder) {
        print("init(coder:) has not been implemented")
        return nil
    }
    
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
