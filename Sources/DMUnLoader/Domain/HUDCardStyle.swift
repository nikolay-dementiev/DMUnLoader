//
//  DMUnLoader
//
//  Created by Mykola Dementiev
//

/// The gray of the card of a HUD. Under Reduce Transparency the card is opaque, so nothing behind it shows
/// through; otherwise it is more opaque while it is shown than while it fades in.
package enum HUDCardStyle {
    package static func backgroundOpacity(isShown: Bool, reducesTransparency: Bool) -> Double {
        if reducesTransparency {
            return 1
        }
        return isShown ? 0.8 : 0.1
    }
}
