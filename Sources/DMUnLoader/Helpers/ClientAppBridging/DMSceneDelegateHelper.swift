//  Created by Mykola Dementiev
//

import UIKit

public protocol DMSceneDelegateHelper {
    static func makeUIKitRootViewHierarhy<LM: DMLoadingManager>(loadingManager: LM) -> UIViewController
}

extension DMSceneDelegateHelper {
    @MainActor
    static func makeUIKitRootViewHierarhy<LM: DMLoadingManager>(loadingManager: LM) -> UIViewController {
        
        UIViewController(nibName: nil, bundle: nil)
    }
}
