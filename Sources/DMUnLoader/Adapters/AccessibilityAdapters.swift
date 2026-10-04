//
//  DMUnLoader
//
//  Created by Mykola Dementiev
//

import os
import UIKit

/// Hides from assistive technology every other window of the HUD's scene at the level of the
/// HUD or below, except the windows of other HUDs. Being modal does not cross windows:
/// `accessibilityViewIsModal` on the HUD window left the app's controls reachable on iOS 17.5,
/// 18.6 and 26.5.
///
/// HUDs that overlap in one scene share the hiding of each window: a window comes back when
/// the last HUD that hides it goes.
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
            .filter { $0 !== hudWindow && !($0 is DMPassThroughWindow) && $0.windowLevel <= hudWindow.windowLevel }
            .map { window in
                WindowHiding.hide(window)
                return HiddenWindow(window: window)
            }
    }

    package func restoreContentUnderneath() {
        for hidden in hiddenWindows {
            if let window = hidden.window {
                WindowHiding.restore(window)
            }
        }
        hiddenWindows = []
    }

    private struct HiddenWindow {
        weak var window: UIWindow?
    }
}

/// How many HUDs hide each window, and whether the window was hidden before the first of them.
@MainActor
private enum WindowHiding {
    private struct Hiding {
        weak var window: UIWindow?
        var count: Int
        let wasHidden: Bool
    }

    private static var hidings: [ObjectIdentifier: Hiding] = [:]

    static func hide(_ window: UIWindow) {
        let key = ObjectIdentifier(window)
        if var hiding = hidings[key], hiding.window === window {
            hiding.count += 1
            hidings[key] = hiding
        } else {
            // A key whose window went away belongs to a new window now.
            hidings[key] = Hiding(window: window, count: 1, wasHidden: window.accessibilityElementsHidden)
            window.accessibilityElementsHidden = true
        }
    }

    static func restore(_ window: UIWindow) {
        let key = ObjectIdentifier(window)
        guard var hiding = hidings[key], hiding.window === window else {
            // A hider restores only the windows it hid, and those stay counted until then.
            Logger(subsystem: "DMUnLoader", category: "accessibility")
                .fault("""
                    A window of type \(String(describing: type(of: window)), privacy: .public) at level \
                    \(window.windowLevel.rawValue, privacy: .public) was given back to assistive technology \
                    that no HUD had hidden.
                    """)
            return
        }
        hiding.count -= 1
        if hiding.count > 0 {
            hidings[key] = hiding
        } else {
            hidings[key] = nil
            window.accessibilityElementsHidden = hiding.wasHidden
        }
    }
}

/// Tells VoiceOver, and the assistive technologies that follow its notifications, what the
/// HUD does.
@MainActor
package final class SystemAccessibilityAnnouncer: AccessibilityAnnouncer {
    private let postScreenChanged: @MainActor (AnyObject?) -> Void

    /// - Parameter postScreenChanged: Posts the screen-changed notification with the element to
    ///   focus. The default calls `UIAccessibility.post`.
    package init(postScreenChanged: @escaping @MainActor (AnyObject?) -> Void = { element in
        UIAccessibility.post(notification: .screenChanged, argument: element)
    }) {
        self.postScreenChanged = postScreenChanged
    }

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
            postScreenChanged(element)
        }
    }
}
