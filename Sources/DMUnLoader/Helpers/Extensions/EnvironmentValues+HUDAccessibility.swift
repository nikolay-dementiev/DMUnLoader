//
//  DMUnLoader
//
//  Created by Mykola Dementiev
//

import SwiftUI

private struct HUDReducesMotionKey: EnvironmentKey {
    static let defaultValue = false
}

private struct HUDReducesTransparencyKey: EnvironmentKey {
    static let defaultValue = false
}

extension EnvironmentValues {
    /// Whether the HUD keeps still: its card fades in without growing, and a pressed button
    /// keeps its size. The HUD's window takes it from the system's Reduce Motion.
    package var hudReducesMotion: Bool {
        get { self[HUDReducesMotionKey.self] }
        set { self[HUDReducesMotionKey.self] = newValue }
    }

    /// Whether the HUD draws neither a blur nor a material behind its card, only a dim. The
    /// HUD's window takes it from the system's Reduce Transparency.
    package var hudReducesTransparency: Bool {
        get { self[HUDReducesTransparencyKey.self] }
        set { self[HUDReducesTransparencyKey.self] = newValue }
    }
}
