//
//  DMUnLoader
//
//  Created by Mykola Dementiev
//

import SwiftUI
import UIKit

/// Shows the HUD in a window of its own, above the other windows of one scene.
@MainActor
package final class OverlayWindowPresenter: HUDOverlayPresenting {
    package typealias Content = HUDComposition

    // A var: `weak let` needs Swift 6.3, and the floor compiler (Xcode 26.0.1) is Swift 6.2.
    private weak var windowScene: UIWindowScene?
    private let announcer: any AccessibilityAnnouncer
    private var window: DMPassThroughWindow?
    private var hudController: UIHostingController<AnyView>?
    private var accessibility: HUDStateReporter?

    /// A presenter that tells VoiceOver what the HUD does.
    convenience init(windowScene: UIWindowScene) {
        self.init(windowScene: windowScene, announcer: SystemAccessibilityAnnouncer())
    }

    /// - Parameters:
    ///   - windowScene: The scene whose windows the HUD covers.
    ///   - announcer: What tells assistive technology about the HUD. A test gives one that records what
    ///     it is told. There is no default value: a default that makes a main-actor object is not
    ///     isolated in the Swift 5 language mode of the pod.
    package init(windowScene: UIWindowScene, announcer: any AccessibilityAnnouncer) {
        self.windowScene = windowScene
        self.announcer = announcer
    }

    /// Shows the HUD of the composition in `presentation`. A HUD shown before gives its window, and its
    /// controller, to this one. Does nothing once the scene is gone.
    package func present(_ presentation: HUDPresentation<HUDComposition>) {
        guard let windowScene else {
            return
        }
        // One window per scene: a new manager gets the window, and the controller, of the
        // one it replaces. The root view is swapped, so the replaced manager is released.
        let window = self.window ?? DMPassThroughWindow(windowScene: windowScene)
        self.window = window
        let accessibility = self.accessibility ?? HUDStateReporter(
            coordinator: HUDAccessibilityCoordinator(
                announcer: announcer,
                contentHider: SceneContentHider(hudWindow: window) { [weak window] in
                    window?.windowScene?.windows ?? []
                }
            )
        )
        self.accessibility = accessibility
        // The window knows the state before it becomes visible; the view reports every
        // change after that. The window owns the view, so the view holds it weakly.
        let composition = presentation.content
        window.interceptsTouches = composition.showsHUD
        let rootView = composition.makeRoot { [weak window, weak accessibility] state in
            window?.interceptsTouches = state.showsHUD
            accessibility?.report(state)
        }
        if let hudController {
            hudController.rootView = rootView
        } else {
            let hudController = UIHostingController(rootView: rootView)
            hudController.view.backgroundColor = .clear
            window.rootViewController = hudController
            self.hudController = hudController
        }
        // The escape does what a tap outside the card does. The handler holds the manager
        // weakly, so the window keeps no replaced manager alive.
        window.escapeHandler = composition.escape
        // Set on every call, so a new manager that takes over the window brings its own level. The
        // windows that the HUD hides depend on that level, so the accessibility side is told when it
        // moved, and only after it moved: it reads the level of the window when it works them out.
        // Read once: the composition asks the settings of its manager each time, so two reads could differ.
        let level = composition.windowLevel
        let levelChanged = window.windowLevel != level
        window.windowLevel = level
        if levelChanged {
            accessibility.hudWindowLevelDidChange()
        }
        window.isHidden = false
    }

    package func dismiss() {
        accessibility?.hudDidGo()
        accessibility = nil
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
