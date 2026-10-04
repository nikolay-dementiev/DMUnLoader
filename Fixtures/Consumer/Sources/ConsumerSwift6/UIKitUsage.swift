import UIKit
import DMUnLoader

final class AppDelegate: UIResponder, UIApplicationDelegate {
    func application(
        _ application: UIApplication,
        configurationForConnecting connectingSceneSession: UISceneSession,
        options: UIScene.ConnectionOptions
    ) -> UISceneConfiguration {
        let configuration = UISceneConfiguration(
            name: "Default Configuration",
            sessionRole: connectingSceneSession.role
        )
        configuration.delegateClass = DMSceneDelegateTypeUIKit<AppDelegateHelper>.self
        return configuration
    }
}

struct AppDelegateHelper {}

extension AppDelegateHelper: DMSceneDelegateHelper {
    static func makeUIKitRootViewHierarhy<LM: DMLoadingManager>(
        loadingManager: LM
    ) -> UIViewController {
        LoadingViewController(loadingManager: loadingManager)
    }
}

final class LoadingViewController<LM: DMLoadingManager>: UIViewController {
    private let loadingManager: LM
    private let provider = DefaultDMLoadingViewProvider()

    init(loadingManager: LM) {
        self.loadingManager = loadingManager
        super.init(nibName: nil, bundle: nil)
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) is unavailable")
    }

    override func loadView() {
        let button = UIButton(type: .system)
        button.setTitle("Show success", for: .normal)
        button.addTarget(self, action: #selector(showSuccess), for: .touchUpInside)
        view = button
    }

    @objc
    private func showSuccess() {
        loadingManager.showSuccess("Data successfully loaded!", provider: provider)
    }
}
