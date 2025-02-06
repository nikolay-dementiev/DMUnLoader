//
//  MainTabViewControllerUIKit.swift
//  DMErrorHandlingPodExample
//
//  Created by Nikolay Dementiev on 03.02.2025.
//

import UIKit
import Combine
import DMErrorHandling

final class MainTabViewControllerUIKit: UITabBarController {
    
    private(set) weak var globalLoadingManager: GlobalLoadingStateManager!
    
    internal init(manager: GlobalLoadingStateManager? = nil) {
        self.globalLoadingManager = manager
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
            viewController: DefaultSettingsViewController(manager: globalLoadingManager),
            title: "Default",
            imageName: "gearshape"
        )
        
        // Second tab - Custom
        let customVC = createNavController(
            viewController: CustomSettingsViewController(manager: globalLoadingManager),
            title: "Custom",
            imageName: "pencil"
        )
        
        viewControllers = [defaultVC, customVC]
    }
    
    private func createNavController(
        viewController: UIViewController,
        title: String,
        imageName: String) -> UINavigationController {
            
        let navController = UINavigationController(rootViewController: viewController)
        navController.tabBarItem.title = title
        navController.tabBarItem.image = UIImage(systemName: imageName)
        navController.navigationBar.prefersLargeTitles = true
        viewController.navigationItem.title = title
        return navController
    }
}

extension MainTabViewControllerUIKit: DMViewControllerTopLevel {
    func handleLoadingStateChange(_ state: DMErrorHandling.DMLoadableType) {
        view.isUserInteractionEnabled = state != .loading
    }
}

// MARK: - View Controllers for tabs
final class DefaultSettingsViewController: UIViewController {
    private(set) weak var globalLoadingManager: GlobalLoadingStateManager!
    
    internal init(manager: GlobalLoadingStateManager) {
        self.globalLoadingManager = manager
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func loadView() {
        super.loadView()
        
        let newCustedView = ContentViewDefaultSettingsUIKit(provider: DefaultDMLoadingViewProvider(),
                                                            innerView: LoadingContentViewUIKit(),
                                                            manager: globalLoadingManager)
        view = newCustedView
        view.setNeedsUpdateConstraints()
    }
}

final class CustomSettingsViewController: UIViewController {
    private(set) weak var globalLoadingManager: GlobalLoadingStateManager!
    
    internal init(manager: GlobalLoadingStateManager) {
        self.globalLoadingManager = manager
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func loadView() {
        super.loadView()
        
        let newCustedView = ContentViewCustomSettingsUIKit(provider: CustomDMLoadingViewProvider(),
                                                           innerView: LoadingContentViewUIKit(),
                                                           manager: globalLoadingManager)
        view = newCustedView
        view.setNeedsUpdateConstraints()
    }
}
