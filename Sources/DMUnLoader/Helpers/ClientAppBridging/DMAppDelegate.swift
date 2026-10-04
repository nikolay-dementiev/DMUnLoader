import SwiftUI

/// The app delegate of the SwiftUI integration, for `DMLoadingManagerMain`.
public typealias DMAppDelegateType = DMAppDelegate<DMLoadingManagerMain>

/// The app delegate of the SwiftUI integration. Use it with `@UIApplicationDelegateAdaptor`: it
/// gives every scene the scene delegate `DMSceneDelegateBase<LM>`, which the released
/// initializers of `DMRootLoadingView` read from the environment.
public final class DMAppDelegate<LM: DMLoadingManager>: NSObject, UIApplicationDelegate {
    /// Returns a configuration whose scene delegate class is `DMSceneDelegateBase<LM>`.
    public func application(
        _ application: UIApplication,
        configurationForConnecting connectingSceneSession: UISceneSession,
        options: UIScene.ConnectionOptions
    ) -> UISceneConfiguration {
        let sceneConfig = UISceneConfiguration(name: nil, sessionRole: connectingSceneSession.role)
        sceneConfig.delegateClass = DMSceneDelegateBase<LM>.self
        return sceneConfig
    }
}
