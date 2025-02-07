//
//  DMErrorHandlingPodExampleApp.swift
//  DMErrorHandlingPodExample
//
//  Created by Nikolay Dementiev on 22.01.2025.
//


import UIKit
import SwiftUI

#if USE_COCOAPODS
import DMErrorHandling
#elseif USE_SPM
import DMErrorHandling
#endif

#if UIKIT_APP

@main
class AppDelegate: UIResponder, UIApplicationDelegate {
    var window: UIWindow?
    
    func application(_ application: UIApplication, willFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        
        AppDelegateHelper.checkDependenciesManagerInUse()
        
        return true
    }

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        window = UIWindow(frame: UIScreen.main.bounds)
        
        let appDelegateHelper = AppDelegateHelper()
        
        let rootVC = appDelegateHelper.makeUIKitRootViewHierarhy()
        
        window?.rootViewController = rootVC
        window?.makeKeyAndVisible()
        return true
    }
}

#elseif SWIFTUI_APP

@main
struct DMErrorHandlingPodExampleApp: App {
    init(){
        AppDelegateHelper.checkDependenciesManagerInUse()
    }
    
    var body: some Scene {
        WindowGroup {
            AppDelegateHelper.RootLoadingView()
        }
    }
}
#endif


private struct AppDelegateHelper {
    
    func makeUIKitRootViewHierarhy() -> DMRootViewControllerUIKit<UIView> {
        let rootVC = DMRootViewControllerUIKit()
        
        let tabViewController = MainTabViewControllerUIKit(manager: rootVC.getLoadingManager())
        
        // Add MainTabViewControllerUIKit as a child controller
        tabViewController.willMove(toParent: rootVC)
        rootVC.addChild(tabViewController)
        tabViewController.view.frame = rootVC.view.bounds
        tabViewController.view.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        rootVC.view.addSubview(tabViewController.view)
        tabViewController.didMove(toParent: rootVC)
        
        return rootVC
    }
    
    static func checkDependenciesManagerInUse() {
#if USE_COCOAPODS
print("Start>> Using CocoaPods ✅")
#elseif USE_SPM
print("Start>> Using Swift Package Manager ✅")
#else
print("❌ No package manager detected!")
#endif
    }
    
    struct RootLoadingView: View {
        var body: some View {
            DMRootLoadingView { _ in
                MainTabView()
            }
        }
    }
    
    struct MainTabView: View {
        var body: some View {
            TabView {
                ContentViewDefaultSettings()
                    .tabItem {
                        Label("Default", systemImage: "gearshape")
                    }
                
                ContentViewCustomSettings()
                    .tabItem {
                        Label("Custom", systemImage: "pencil")
                    }
            }
        }
    }
}
