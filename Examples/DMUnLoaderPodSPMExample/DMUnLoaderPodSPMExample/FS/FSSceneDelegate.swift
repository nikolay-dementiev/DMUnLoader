import SwiftUI
import DMUnLoader

final class FSSceneDelegate<LM: DMLoadingManagerInteralProtocol>: UIResponder, UIWindowSceneDelegate, ObservableObject {
    var loadingManager: LM? {
        didSet {
            setupHudWindow()
        }
    }
    
    var toastWindow: UIWindow?
    weak var windowScene: UIWindowScene?
    
    func scene(
        _ scene: UIScene,
        willConnectTo session: UISceneSession,
        options connectionOptions: UIScene.ConnectionOptions
    ) {
        windowScene = scene as? UIWindowScene
    }
    
    func setupHudWindow() {
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
