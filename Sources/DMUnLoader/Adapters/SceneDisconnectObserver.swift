//
//  DMUnLoader
//
//  Created by Mykola Dementiev
//

import UIKit

/// The one call of a notification center that observing a scene's disconnect needs.
package protocol NotificationObserverRegistering: AnyObject {
    func addObserver(_ observer: Any, selector: Selector, name: NSNotification.Name?, object: Any?)
}

extension NotificationCenter: NotificationObserverRegistering {}

/// Calls `onDisconnect` when UIKit posts `UIScene.didDisconnectNotification` for one scene.
/// The registration lasts as long as this object.
@MainActor
package final class SceneDisconnectObserver: NSObject {
    private let onDisconnect: @MainActor () -> Void

    /// - Parameters:
    ///   - scene: The scene whose disconnect is reported. Notifications of other scenes are ignored.
    ///   - notificationCenter: The center UIKit posts the notification to.
    ///   - onDisconnect: Called on the main actor when `scene` disconnects.
    package init(
        scene: AnyObject,
        notificationCenter: any NotificationObserverRegistering,
        onDisconnect: @escaping @MainActor () -> Void
    ) {
        self.onDisconnect = onDisconnect
        super.init()
        notificationCenter.addObserver(
            self,
            selector: #selector(sceneDidDisconnect),
            name: UIScene.didDisconnectNotification,
            object: scene
        )
    }

    @objc private func sceneDidDisconnect() {
        onDisconnect()
    }
}
