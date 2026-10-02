import SwiftUI

public typealias DMSceneDelegateTypeUIKit<Helper: DMSceneDelegateHelper> = DMSceneDelegateUIKit<DMLoadingManagerMain, Helper>

/// The scene delegate of the UIKit integration. When its scene connects it creates a
/// loading manager, asks `Helper` for the root view controller of the scene's main window
/// and shows the HUD of that manager in a window of its own, above the main window.
public final class DMSceneDelegateUIKit<
    LM: DMLoadingManager,
    Helper: DMSceneDelegateHelper
>: UIResponder, UIWindowSceneDelegate, ObservableObject {
    
    private let decoratee = DMSceneDelegateBase<LM>()
    
    /// The loading manager of the scene, created when the scene connects. It is set after
    /// `Helper` built the root view controller, which receives the same manager as its
    /// argument. Setting it works as `DMSceneDelegateBase.loadingManager` describes.
    public var loadingManager: LM? {
        get { decoratee.loadingManager }
        set { decoratee.loadingManager = newValue }
    }
    
    var windowScene: UIWindowScene? {
        decoratee.windowScene
    }
    
    var keyWindow: UIWindow?
    
    public func scene(
        _ scene: UIScene,
        willConnectTo session: UISceneSession,
        options connectionOptions: UIScene.ConnectionOptions
    ) {
        guard let windowScene = scene as? UIWindowScene else {
            return
        }
        
        decoratee.scene(windowScene,
                        willConnectTo: session,
                        options: connectionOptions)

        let loadingManager = LM()
        setupMainWindow(in: windowScene, loadingManager: loadingManager)
        // Handed over after the main window is shown, so the HUD window is created above it.
        self.loadingManager = loadingManager
    }

    private func setupMainWindow(in scene: UIWindowScene, loadingManager: LM) {
        guard windowScene != nil else {
            return
        }

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
    private var disconnectObserver: SceneDisconnectObserver?
    weak var windowScene: UIWindowScene?

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
        disconnectObserver = SceneDisconnectObserver(
            scene: windowScene,
            notificationCenter: NotificationCenter.default
        ) { [weak self] in
            self?.overlay.sceneDidDisconnect()
        }
        overlay.sceneDidConnect(presenter: OverlayWindowPresenter(windowScene: windowScene))
    }
}
