//
//  MultipleScenesWithinSwiftUI-MVP
//
//  Created by Mykola Dementiev
//


import SwiftUI

public final class MVPAppDelegate: NSObject, UIApplicationDelegate {
    public func application(
        _ application: UIApplication,
        configurationForConnecting connectingSceneSession: UISceneSession,
        options: UIScene.ConnectionOptions
    ) -> UISceneConfiguration {
        let sceneConfig = UISceneConfiguration(name: nil, sessionRole: connectingSceneSession.role)
        sceneConfig.delegateClass = MVPSceneDelegate.self // 👈🏻
        return sceneConfig
    }
}
