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
    private weak var windowScene: UIWindowScene?
    private var window: DMPassThroughWindow?

    init(windowScene: UIWindowScene) {
        self.windowScene = windowScene
    }

    func present<LM: DMLoadingManager>(_ loadingManager: LM) {
        guard let windowScene else {
            return
        }
        let window = DMPassThroughWindow(windowScene: windowScene)
        // The window knows the state before it becomes visible; the view reports every
        // change after that. The window owns the view, so the view holds it weakly.
        window.interceptsTouches = loadingManager.loadableState.showsHUD
        let hudController = UIHostingController(
            rootView: DMHudSceneView(loadingManager: loadingManager) { [weak window] showsHUD in
                window?.interceptsTouches = showsHUD
            }
        )
        hudController.view.backgroundColor = .clear
        window.rootViewController = hudController
        window.isHidden = false
        self.window = window
    }
}
