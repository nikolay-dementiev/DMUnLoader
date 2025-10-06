//  Created by Mykola Dementiev
//

import UIKit

public protocol FSSceneDelegateHelper {
    @MainActor
    static func makeLoadingManager<LM>() -> LM where LM: DMLoadingManagerProtocol
    
    static func makeUIKitRootViewHierarhy<LM: DMLoadingManagerProtocol>(loadingManager: LM) -> UIViewController
}

extension FSSceneDelegateHelper {
    @MainActor
    public static func makeLoadingManager<LM: DMLoadingManagerProtocol>() -> LM {
        LM()
    }
    
    static func makeUIKitRootViewHierarhy<LM: DMLoadingManagerProtocol>(loadingManager: LM) -> UIViewController {
        
        UIViewController(nibName: nil, bundle: nil)
    }
}
