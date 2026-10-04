//
//  DMUnLoader
//
//  Created by Mykola Dementiev
//

import SwiftUI

/// Hands the system's Reduce Motion and Reduce Transparency to the views of the HUD.
///
/// The views read the HUD's own values, `hudReducesMotion` and `hudReducesTransparency`: the
/// system's values cannot be set, so a test that inspects a view without rendering it sets
/// the HUD's values instead.
package struct SystemAccessibilitySettings: ViewModifier {
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @Environment(\.accessibilityReduceTransparency) private var reduceTransparency

    package init() {}

    package func body(content: Content) -> some View {
        content
            .environment(\.hudReducesMotion, reduceMotion)
            .environment(\.hudReducesTransparency, reduceTransparency)
    }
}
