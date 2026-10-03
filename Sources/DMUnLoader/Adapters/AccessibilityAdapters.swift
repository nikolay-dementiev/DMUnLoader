//
//  DMUnLoader
//
//  Created by Mykola Dementiev
//

import UIKit

/// Hides from assistive technology every other window of the HUD's scene at the level of the
/// HUD or below. Being modal does not cross windows: `accessibilityViewIsModal` on the HUD
/// window left the app's controls reachable on iOS 17.5, 18.6 and 26.5.
@MainActor
package final class SceneContentHider: ContentUnderneathHiding {
    private weak var hudWindow: UIWindow?
    private let windowsOfTheScene: @MainActor () -> [UIWindow]
    private var hiddenWindows: [HiddenWindow] = []

    /// - Parameters:
    ///   - hudWindow: The window of the HUD, which stays reachable.
    ///   - windowsOfTheScene: The windows of the HUD's scene, read when the content is hidden.
    package init(hudWindow: UIWindow, windowsOfTheScene: @escaping @MainActor () -> [UIWindow]) {
        self.hudWindow = hudWindow
        self.windowsOfTheScene = windowsOfTheScene
    }

    package func hideContentUnderneath() {
        restoreContentUnderneath()
        guard let hudWindow else {
            return
        }
        hiddenWindows = windowsOfTheScene()
            .filter { $0 !== hudWindow && $0.windowLevel <= hudWindow.windowLevel }
            .map { window in
                let hidden = HiddenWindow(window: window, wasHidden: window.accessibilityElementsHidden)
                window.accessibilityElementsHidden = true
                return hidden
            }
    }

    package func restoreContentUnderneath() {
        for hidden in hiddenWindows {
            hidden.window?.accessibilityElementsHidden = hidden.wasHidden
        }
        hiddenWindows = []
    }

    private struct HiddenWindow {
        weak var window: UIWindow?
        let wasHidden: Bool
    }
}

/// Tells VoiceOver, and the assistive technologies that follow its notifications, what the
/// HUD does.
@MainActor
package final class SystemAccessibilityAnnouncer: AccessibilityAnnouncer {
    package init() {}

    package var focusedElement: AnyObject? {
        UIAccessibility.focusedElement(using: .notificationVoiceOver) as AnyObject?
    }

    package func isOnScreen(_ element: AnyObject) -> Bool {
        var current: Any? = element
        while let candidate = current {
            if let view = candidate as? UIView {
                return view.window != nil
            }
            current = (candidate as? UIAccessibilityElement)?.accessibilityContainer
        }
        // An element that names no view cannot be checked; VoiceOver ignores one that is gone.
        return true
    }

    package func screenChanged(focusing element: AnyObject?) {
        // The HUD window changes in this turn; the notification follows on the next one.
        Task { @MainActor in
            UIAccessibility.post(notification: .screenChanged, argument: element)
        }
    }
}
