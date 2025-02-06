//
//  DMErrorHandlingPodExampleApp.swift
//  DMErrorHandlingPodExample
//
//  Created by Nikolay Dementiev on 22.01.2025.
//


import UIKit
import SwiftUI
import DMErrorHandling

#if UIKIT_APP

@main
class AppDelegate: UIResponder, UIApplicationDelegate {
    var window: UIWindow?

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
        
        let tabViewControlelr = MainTabViewControllerUIKit(manager: rootVC.getLoadingManager())
        
        // Add MainTabViewControllerUIKit as a child controller
        tabViewControlelr.willMove(toParent: rootVC)
        rootVC.addChild(tabViewControlelr)
        tabViewControlelr.view.frame = rootVC.view.bounds
        tabViewControlelr.view.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        rootVC.view.addSubview(tabViewControlelr.view)
        tabViewControlelr.didMove(toParent: rootVC)
        
        return rootVC
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
