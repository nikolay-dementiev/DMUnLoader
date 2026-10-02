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
        
        self.loadingManager = .init()
        
        setupMainWindow(in: windowScene)
        setupHudWindow(in: windowScene)
    }
    
    func setupHudWindow(in scene: UIWindowScene) {
        decoratee.setupHudWindow(in: scene)
    }
    
    private func setupMainWindow(in scene: UIWindowScene) {
        guard windowScene != nil,
              let loadingManager = loadingManager else {
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
        overlay.sceneDidConnect(presenter: OverlayWindowPresenter(windowScene: windowScene))
    }

    func setupHudWindow(in scene: UIWindowScene) {
        overlay.loadingManagerDidChange(to: loadingManager)
    }
}
