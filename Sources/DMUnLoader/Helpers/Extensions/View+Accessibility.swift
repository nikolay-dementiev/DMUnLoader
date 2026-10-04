//
//  DMUnLoader
//
//  Created by Mykola Dementiev
//

import SwiftUI

extension View {
    /// Hides the view from assistive technology when `hidden` is true, and adds nothing
    /// otherwise, so the view keeps the accessibility it was given.
    @ViewBuilder
    func hiddenFromAccessibility(if hidden: Bool) -> some View {
        if hidden {
            accessibilityHidden(true)
        } else {
            self
        }
    }
}
