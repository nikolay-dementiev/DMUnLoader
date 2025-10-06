import SwiftUI

public final class FSSceneDelegateUIKit<
    LM: DMLoadingManagerProtocol,
    Helper: FSSceneDelegateHelper
>: UIResponder, UIWindowSceneDelegate, ObservableObject {
    
    private let decoratee = FSSceneDelegateSwiftUI<LM>()
    private typealias helper = Helper
    
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
        
        self.loadingManager = helper.makeLoadingManager()
        
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
        
        let rootVC = helper.makeUIKitRootViewHierarhy(loadingManager: loadingManager)

        window.rootViewController = rootVC
        self.keyWindow = window
        window.makeKeyAndVisible()
    }
}

public final class FSSceneDelegateSwiftUI<
    LM: DMLoadingManagerProtocol
>: UIResponder, UIWindowSceneDelegate, ObservableObject {
    public var loadingManager: LM? {
        didSet {
            guard let windowScene else {
                return
            }
            setupHudWindow(in: windowScene)
        }
    }
    
    private var toastWindow: UIWindow?
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
    }
    
    func setupHudWindow(in scene: UIWindowScene) {
        guard let windowScene = windowScene,
              let loadingManager = loadingManager else {
            return
        }
        
        let toastViewController = UIHostingController(rootView: HudSceneView(loadingManager: loadingManager))
        
        toastViewController.view.backgroundColor = .clear
        
        let toastWindow = PassThroughWindow(windowScene: windowScene)
        toastWindow.rootViewController = toastViewController
        toastWindow.isHidden = false
        self.toastWindow = toastWindow
    }
}
