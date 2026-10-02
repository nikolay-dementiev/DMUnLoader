//
//  DMUnLoader
//
//  Created by Mykola Dementiev
//

import UIKit

/// The window of the HUD. It takes no touch while no HUD is shown, so the app under it
/// gets every touch, and every touch while a HUD is shown, so the HUD is modal.
///
/// The owner sets which of the two applies from the state of the loading manager. The
/// window does not guess it from the view a touch lands on: SwiftUI does not promise
/// which view that is, and on iOS 18 and later a touch on a SwiftUI button lands on the
/// hosting view itself.
package final class DMPassThroughWindow: UIWindow {
    /// Whether a HUD is shown and the window takes the touches.
    package var interceptsTouches = false

    package override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
        guard interceptsTouches else { return nil }
        return super.hitTest(point, with: event)
    }
}
