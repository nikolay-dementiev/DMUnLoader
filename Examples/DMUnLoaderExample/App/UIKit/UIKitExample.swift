import UIKit
import DMUnLoader

/// The UIKit integration.
///
/// The app delegate names `DMSceneDelegateUIKit` as the scene delegate. That scene delegate
/// creates the loading manager, asks the helper for the root view controller and puts the
/// HUD window above it.
enum UIKitExample {
    @MainActor
    static func run() {
        _ = UIApplicationMain(
            CommandLine.argc,
            CommandLine.unsafeArgv,
            nil,
            NSStringFromClass(UIKitAppDelegate.self)
        )
    }
}

final class UIKitAppDelegate: UIResponder, UIApplicationDelegate {
    func application(
        _ application: UIApplication,
        configurationForConnecting connectingSceneSession: UISceneSession,
        options: UIScene.ConnectionOptions
    ) -> UISceneConfiguration {
        let configuration = UISceneConfiguration(name: nil, sessionRole: connectingSceneSession.role)
        configuration.delegateClass = LaunchOptions.current.usesCustomManager
            ? DMSceneDelegateUIKit<StickyLoadingManager, UIKitSceneHelper>.self
            : DMSceneDelegateTypeUIKit<UIKitSceneHelper>.self
        return configuration
    }
}

/// Supplies the root view controller. The library's requirement is not isolated to the
/// main actor, so the conformance states the isolation it needs to build a view controller.
/// An isolated conformance needs a Swift 6.2 compiler; in Swift 5 language mode a plain
/// conformance, as in the README, compiles as well.
@MainActor
enum UIKitSceneHelper: @MainActor DMSceneDelegateHelper {
    static func makeUIKitRootViewHierarhy<LM: DMLoadingManager>(loadingManager: LM) -> UIViewController {
        ConstructionWitness.record(loadingManager: loadingManager)
        return DemoViewController(model: DemoModel(loadingManager: loadingManager))
    }
}
