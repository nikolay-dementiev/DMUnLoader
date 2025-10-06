import SwiftUI

public final class FSAppDelegate<LM: DMLoadingManagerProtocol>: NSObject, UIApplicationDelegate {
    public func application(
        _ application: UIApplication,
        configurationForConnecting connectingSceneSession: UISceneSession,
        options: UIScene.ConnectionOptions
    ) -> UISceneConfiguration {
        let sceneConfig = UISceneConfiguration(name: nil, sessionRole: connectingSceneSession.role)
        sceneConfig.delegateClass = FSSceneDelegateSwiftUI<LM>.self // 👈🏻
        return sceneConfig
    }
}
