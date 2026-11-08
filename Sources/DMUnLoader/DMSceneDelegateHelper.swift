//  Created by Mykola Dementiev
//

import UIKit

/// Supplies the root view controller of a scene to the UIKit integration, `DMSceneDelegateUIKit`.
public protocol DMSceneDelegateHelper {
    /// Returns the root view controller of the main window of a scene. The library calls it on
    /// the main actor, once for each scene that connects, with the loading manager of that scene.
    /// The name keeps its released spelling until 2.0.0.
    static func makeUIKitRootViewHierarhy<LM: DMLoadingManager>(loadingManager: LM) -> UIViewController
}

extension DMSceneDelegateHelper {
    @MainActor
    static func makeUIKitRootViewHierarhy<LM: DMLoadingManager>(loadingManager: LM) -> UIViewController {
        
        UIViewController(nibName: nil, bundle: nil)
    }
}
