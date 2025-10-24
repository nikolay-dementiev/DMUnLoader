//
//  DMUnLoaderPodExample
//
//  Created by Mykola Dementiev
//

import UIKit
import Combine
import DMUnLoader

final class MainTabViewControllerUIKit<LM: DMLoadingManager>: UITabBarController {
    
    private(set) weak var loadingManager: LM?
    
    init(loadingManager: LM?) {
        self.loadingManager = loadingManager
        
        super.init(nibName: nil, bundle: nil)
    }
   
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupTabs()
    }
    
    private func setupTabs() {
        // First tab - Default
        let defaultVC = createNavController(
            viewController: DefaultSettingsViewController(
                loadingManager: loadingManager
            ),
            buttonTitle: "Default",
            imageName: "gearshape",
            navigatioTitle: "Default settings"
        )
        
        // Second tab - Custom
        let customVC = createNavController(
            viewController: CustomSettingsViewController(
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

// MARK: - View Controllers for tabs

final class DefaultSettingsViewController<LM: DMLoadingManager>: UIViewController {
    private(set) weak var loadingManager: LM?
    
    init(loadingManager: LM?) {
        self.loadingManager = loadingManager
        super.init(nibName: nil, bundle: nil)
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func loadView() {
        super.loadView()
        
        let newCustedView = configureContentViewSettingsView(
            provider: DefaultDMLoadingViewProvider(),
            innerView: LoadingContentViewUIKit(),
            loadingManager: loadingManager
        )
        
        view = newCustedView
        view.setNeedsUpdateConstraints()
    }
}

final class CustomSettingsViewController<LM: DMLoadingManager>: UIViewController {
    private(set) weak var loadingManager: LM?
    
    init(loadingManager: LM?) {
        self.loadingManager = loadingManager
        super.init(nibName: nil, bundle: nil)
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func loadView() {
        super.loadView()
        
        let newCustedView = configureContentViewSettingsView(
            provider: CustomDMLoadingViewProvider(),
            innerView: LoadingContentViewUIKit(),
            loadingManager: loadingManager
        )
        
        view = newCustedView
        view.setNeedsUpdateConstraints()
    }
}

private extension UIViewController {
    func configureContentViewSettingsView<
        LM: DMLoadingManager,
        LVP: DMLoadingViewProvider
    >(
        provider: LVP,
        innerView: LoadingContentViewUIKit<LVP, LM>,
        loadingManager: LM?
    ) -> UIView {
        
        innerView.configure(
            loadingManager: loadingManager,
            provider: provider
        )
        
        return innerView
    }
}
