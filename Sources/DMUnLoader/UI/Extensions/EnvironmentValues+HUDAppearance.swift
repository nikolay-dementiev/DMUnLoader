//
//  DMUnLoader
//
//  Created by Mykola Dementiev
//

import SwiftUI

private struct HUDAppearanceKey: EnvironmentKey {
    static let defaultValue = DMHUDAppearance.standard
}

extension EnvironmentValues {
    /// The look of the HUD for the state it draws: that of the provider of the state. The HUD sets it
    /// for the views of its card, and the library's own views read it to choose their layout.
    package var hudAppearance: DMHUDAppearance {
        get { self[HUDAppearanceKey.self] }
        set { self[HUDAppearanceKey.self] = newValue }
    }
}
