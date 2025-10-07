//  Created by Mykola Dementiev
//

import UIKit

public protocol FSSceneDelegateHelper {
    static func makeUIKitRootViewHierarhy<LM: DMLoadingManagerProtocol>(loadingManager: LM) -> UIViewController
}

extension FSSceneDelegateHelper {
    static func makeUIKitRootViewHierarhy<LM: DMLoadingManagerProtocol>(loadingManager: LM) -> UIViewController {
        
        UIViewController(nibName: nil, bundle: nil)
    }
}
