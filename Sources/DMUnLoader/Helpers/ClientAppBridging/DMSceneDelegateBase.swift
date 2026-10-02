import SwiftUI

public typealias DMSceneDelegateTypeUIKit<Helper: DMSceneDelegateHelper> = DMSceneDelegateUIKit<DMLoadingManagerMain, Helper>

public final class DMSceneDelegateUIKit<
    LM: DMLoadingManager,
    Helper: DMSceneDelegateHelper
>: UIResponder, UIWindowSceneDelegate, ObservableObject {
    
    private let decoratee = DMSceneDelegateBase<LM>()
    
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

public final class DMSceneDelegateBase<
    LM: DMLoadingManager
>: UIResponder, UIWindowSceneDelegate, ObservableObject {
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
