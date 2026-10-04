//
//  DMUnLoader
//
//  Created by Mykola Dementiev
//

import UIKit

/// A window scene shows HUDs in a window of their own, and reports its disconnect through
/// `UIScene.didDisconnectNotification`.
extension UIWindowScene: HUDScene {
    package func makeHUDPresenter() -> any HUDOverlayPresenting {
        OverlayWindowPresenter(windowScene: self)
    }

    package func observeDisconnect(_ onDisconnect: @escaping @MainActor () -> Void) -> AnyObject {
        SceneDisconnectObserver(scene: self, notificationCenter: NotificationCenter.default, onDisconnect: onDisconnect)
    }
}
