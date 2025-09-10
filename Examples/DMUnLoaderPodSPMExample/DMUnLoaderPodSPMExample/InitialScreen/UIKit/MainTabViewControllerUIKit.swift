//
//  DMUnLoaderPodExample
//
//  Created by Mykola Dementiev
//

import UIKit
import Combine
import DMUnLoader

final class MainTabViewControllerUIKit<LM: DMLoadingManagerInteralProtocol>: UITabBarController {
    
    private(set) weak var globalLoadingManager: GlobalLoadingStateManager!
    private(set) weak var loadingManager: LM?
    
    internal init(manager: GlobalLoadingStateManager,
                  loadingManager: LM?) {
        self.globalLoadingManager = manager
        self.loadingManager = loadingManager
        
        super.init(nibName: nil, bundle: nil)
    }
   
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupTabs()
        
        subscribeToLoadingStateChange(from: globalLoadingManager)
    }
    
    private func setupTabs() {
        // First tab - Default
        let defaultVC = createNavController(
            viewController: DefaultSettingsViewController(
                manager: globalLoadingManager,
                loadingManager: loadingManager
            ),
            buttonTitle: "Default",
            imageName: "gearshape",
            navigatioTitle: "Default settings"
        )
        
        // Second tab - Custom
        let customVC = createNavController(
            viewController: CustomSettingsViewController(
                manager: globalLoadingManager,
                loadingManager: loadingManager
            ),
            buttonTitle: "Custom",
            imageName: "pencil",
            navigatioTitle: "Custom settings"
        )
        
        viewControllers = [defaultVC, customVC]
    }
    
    private func createNavController(
        viewController: UIViewController,
        buttonTitle: String,
        imageName: String,
        navigatioTitle: String) -> UINavigationController {
            
        let navController = UINavigationController(rootViewController: viewController)
        navController.tabBarItem.title = buttonTitle
        navController.tabBarItem.image = UIImage(systemName: imageName)
        navController.navigationBar.prefersLargeTitles = true
        viewController.navigationItem.title = navigatioTitle
        return navController
    }
}

extension MainTabViewControllerUIKit: DMViewControllerTopLevel {
    func handleLoadingStateChange(_ state: DMUnLoader.DMLoadableType) {
        view.isUserInteractionEnabled = state != .loading
    }
}

// MARK: - View Controllers for tabs

final class DefaultSettingsViewController<LM: DMLoadingManagerInteralProtocol>: UIViewController {
    private(set) weak var globalLoadingManager: GlobalLoadingStateManager!
    private(set) weak var loadingManager: LM?
    
    internal init(manager: GlobalLoadingStateManager,
                  loadingManager: LM?) {
        self.globalLoadingManager = manager
        self.loadingManager = loadingManager
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func loadView() {
        super.loadView()
        
        let newCustedView = ContentViewDefaultSettingsUIKit(provider: DefaultDMLoadingViewProvider(),
                                                            innerView: LoadingContentViewUIKit<LM>(),
                                                            manager: globalLoadingManager,
                                                            loadingManager: loadingManager)
        view = newCustedView
        view.setNeedsUpdateConstraints()
    }
}

final class CustomSettingsViewController<LM: DMLoadingManagerInteralProtocol>: UIViewController {
    private(set) weak var globalLoadingManager: GlobalLoadingStateManager!
    private(set) weak var loadingManager: LM?
    
    internal init(manager: GlobalLoadingStateManager,
                  loadingManager: LM?) {
        self.globalLoadingManager = manager
        self.loadingManager = loadingManager
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func loadView() {
        super.loadView()
        
        let newCustedView = ContentViewCustomSettingsUIKit(provider: CustomDMLoadingViewProvider(),
                                                           innerView: LoadingContentViewUIKit(),
                                                           manager: globalLoadingManager,
                                                           loadingManager: loadingManager)
        view = newCustedView
        view.setNeedsUpdateConstraints()
    }
}
