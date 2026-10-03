//
//  DMUnLoader
//
//  Created by Mykola Dementiev
//

import SwiftUI

private struct HUDTextsKey: EnvironmentKey {
    static let defaultValue: any HUDTexts = BundleHUDTexts()
}

extension EnvironmentValues {
    /// The default texts of the HUD in the language of the app: the library's catalog unless a
    /// test gives other texts.
    package var hudTexts: any HUDTexts {
        get { self[HUDTextsKey.self] }
        set { self[HUDTextsKey.self] = newValue }
    }
}
