import SwiftUI

/// The scene delegate of the UIKit integration, for `DMLoadingManagerMain` and the root view
/// controller of `Helper`.
public typealias DMSceneDelegateTypeUIKit<Helper: DMSceneDelegateHelper> = DMSceneDelegateUIKit<DMLoadingManagerMain, Helper>

/// The scene delegate of the UIKit integration. When its scene connects it creates a
/// loading manager, asks `Helper` for the root view controller of the scene's main window
/// and shows the HUD of that manager in a window of its own, above the main window.
public final class DMSceneDelegateUIKit<
    LM: DMLoadingManager,
    Helper: DMSceneDelegateHelper
>: UIResponder, UIWindowSceneDelegate, ObservableObject {
    
    private let decoratee = DMSceneDelegateBase<LM>()
    
    /// The loading manager of the scene, created when the scene connects. It is set before
    /// `Helper` builds the root view controller, which receives the same manager as its
    /// argument, so the root view controller finds it here. Setting it works as
    /// `DMSceneDelegateBase.loadingManager` describes.
    public var loadingManager: LM? {
        get { decoratee.loadingManager }
        set { decoratee.loadingManager = newValue }
    }
    
    var windowScene: UIWindowScene? {
        decoratee.windowScene
    }
    
    var keyWindow: UIWindow?
    
    /// Creates the loading manager of the scene, shows the main window with the root view
    /// controller of `Helper`, and then shows the HUD of the manager above it. A scene that is
    /// not a window scene gets nothing.
    public func scene(
        _ scene: UIScene,
        willConnectTo session: UISceneSession,
        options connectionOptions: UIScene.ConnectionOptions
    ) {
        guard let windowScene = scene as? UIWindowScene else {
            return
        }
        
        let loadingManager = LM()
        // Set before the main window is built, so the root view controller can read it through
        // this delegate. The HUD connects after the main window is shown, so its window is above it.
        self.loadingManager = loadingManager
        setupMainWindow(in: windowScene, loadingManager: loadingManager)
        decoratee.scene(windowScene,
                        willConnectTo: session,
                        options: connectionOptions)
    }

    private func setupMainWindow(in scene: UIWindowScene, loadingManager: LM) {
        let window = UIWindow(windowScene: scene)
        
        let rootVC = Helper.makeUIKitRootViewHierarhy(loadingManager: loadingManager)

        window.rootViewController = rootVC
        self.keyWindow = window
        window.makeKeyAndVisible()
    }
}

/// The scene delegate that shows the HUD of a loading manager in a window of its own,
/// above the other windows of its scene. The SwiftUI integration installs it through
/// `DMAppDelegate`, and `DMRootLoadingView` hands it the loading manager.
public final class DMSceneDelegateBase<
    LM: DMLoadingManager
>: UIResponder, UIWindowSceneDelegate, ObservableObject {
    /// The loading manager whose HUD the scene shows. Setting a manager shows its HUD, or,
    /// before the scene connects, shows it when the scene connects. Setting the same manager
    /// again keeps its HUD, another manager takes over the HUD window, and `nil` removes the
    /// HUD. When the scene disconnects the HUD is removed and the manager is kept. The
    /// delegate holds the manager strongly; the HUD keeps no replaced manager alive.
    public var loadingManager: LM? {
        didSet {
            overlay.loadingManagerDidChange(to: loadingManager)
        }
    }

    private let overlay = HUDOverlayLifecycle()
    private var disconnectObservation: AnyObject?
    weak var windowScene: UIWindowScene?

    /// Shows the HUD of `loadingManager` over the scene, also when the manager was set before
    /// the scene connected. A scene that is not a window scene gets no HUD.
    public func scene(
        _ scene: UIScene,
        willConnectTo session: UISceneSession,
        options connectionOptions: UIScene.ConnectionOptions
    ) {
        guard let windowScene = scene as? UIWindowScene else {
            return
        }

        self.windowScene = windowScene
        // The notification rather than sceneDidDisconnect(_:), which this public class would
        // have to declare public.
        disconnectObservation = overlay.connect(to: windowScene)
    }
}
