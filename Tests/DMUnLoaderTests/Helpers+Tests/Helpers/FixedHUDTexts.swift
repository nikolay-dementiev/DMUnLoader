//
//  DMUnLoader
//
//  Created by Mykola Dementiev
//

import DMUnLoader

/// The default texts of the HUD with a loading text of the test.
struct FixedHUDTexts: HUDTexts {
    let loading: String

    func text(for role: HUDDefaultText) -> String {
        role == .loadingText ? loading : role.english
    }
}
