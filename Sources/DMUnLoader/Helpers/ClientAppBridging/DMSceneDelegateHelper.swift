//  Created by Mykola Dementiev
//

import UIKit

public protocol DMSceneDelegateHelper {
    static func makeUIKitRootViewHierarhy<LM: DMLoadingManagerProtocol>(loadingManager: LM) -> UIViewController
}

extension DMSceneDelegateHelper {
    static func makeUIKitRootViewHierarhy<LM: DMLoadingManagerProtocol>(loadingManager: LM) -> UIViewController {
        
        UIViewController(nibName: nil, bundle: nil)
    }
}
