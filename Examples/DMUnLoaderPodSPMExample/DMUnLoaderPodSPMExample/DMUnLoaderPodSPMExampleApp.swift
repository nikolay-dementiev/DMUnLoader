//
//  DMUnLoaderPodExample
//
//  Created by Mykola Dementiev
//

import UIKit
import SwiftUI
import DMUnLoader

#if UIKIT_APP

@main
class AppDelegate: UIResponder, UIApplicationDelegate {
    var window: UIWindow?
    
    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        
        let configuration = UISceneConfiguration(name: "Default Configuration",
                                                 sessionRole: connectingSceneSession.role)

        configuration.delegateClass = DMSceneDelegateTypeUIKit<AppDelegateHelper>.self
        
        return configuration
    }
    
    func application(_ application: UIApplication, willFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        
        AppDelegateHelper.makeAppDescriprtion()
        
        return true
    }
}

#elseif SWIFTUI_APP

@main
struct DMUnLoaderPodSPMExampleApp: App {
    @UIApplicationDelegateAdaptor private var delegate: DMAppDelegateType
    
    init() {
        AppDelegateHelper.makeAppDescriprtion()
    }
    
    var body: some Scene {
        WindowGroup {
            DMRootLoadingView { loadingManager in
                MainTabViewSwiftUI(loadingManager: loadingManager)
            }
        }
    }
}

#endif
