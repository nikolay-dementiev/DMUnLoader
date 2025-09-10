import SwiftUI
import DMUnLoader

final class FSAppDelegate<LM: DMLoadingManagerInteralProtocol>: NSObject, UIApplicationDelegate {
  func application(
    _ application: UIApplication,
    configurationForConnecting connectingSceneSession: UISceneSession,
    options: UIScene.ConnectionOptions
  ) -> UISceneConfiguration {
    let sceneConfig = UISceneConfiguration(name: nil, sessionRole: connectingSceneSession.role)
    sceneConfig.delegateClass = FSSceneDelegate<LM>.self // 👈🏻
    return sceneConfig
  }
}
