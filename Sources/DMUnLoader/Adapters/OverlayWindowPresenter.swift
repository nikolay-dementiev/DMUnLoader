//
//  DMUnLoader
//
//  Created by Mykola Dementiev
//

import SwiftUI
import UIKit

/// Shows the HUD in a window of its own, above the other windows of one scene.
@MainActor
final class OverlayWindowPresenter: HUDOverlayPresenting {
    // A var: `weak let` needs Swift 6.3, and the floor compiler (Xcode 26.0.1) is Swift 6.2.
    private weak var windowScene: UIWindowScene?
    private var window: DMPassThroughWindow?
    private var hudController: UIHostingController<AnyView>?

    init(windowScene: UIWindowScene) {
        self.windowScene = windowScene
    }

    func present<LM: DMLoadingManager>(_ loadingManager: LM) {
        guard let windowScene else {
            return
        }
        // One window per scene: a new manager gets the window, and the controller, of the
        // one it replaces. The root view is swapped, so the replaced manager is released.
        let window = self.window ?? DMPassThroughWindow(windowScene: windowScene)
        self.window = window
        // The window knows the state before it becomes visible; the view reports every
        // change after that. The window owns the view, so the view holds it weakly.
        window.interceptsTouches = loadingManager.loadableState.showsHUD
        let rootView = AnyView(
            DMHudSceneView(loadingManager: loadingManager) { [weak window] showsHUD in
                window?.interceptsTouches = showsHUD
            }
        )
        if let hudController {
            hudController.rootView = rootView
        } else {
            let hudController = UIHostingController(rootView: rootView)
            hudController.view.backgroundColor = .clear
            window.rootViewController = hudController
            self.hudController = hudController
        }
        window.isHidden = false
    }

    func dismiss() {
        guard let window else {
            return
        }
        // Hidden is not enough: the scene keeps a window until it leaves the scene.
        window.isHidden = true
        window.rootViewController = nil
        window.windowScene = nil
        self.window = nil
        hudController = nil
    }
}
