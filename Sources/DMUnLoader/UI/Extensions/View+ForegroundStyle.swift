//
//  DMUnLoader
//
//  Created by Mykola Dementiev
//

import SwiftUI

extension View {
    /// Sets the foreground style to `style`, or leaves the view as it is when `style` is `nil`.
    ///
    /// Retired: removed in 2.0.0. Apply a style only when you have one, with `if let style` in a
    /// view builder. `style ?? .primary` is not the same: it sets a style where this overload
    /// leaves the one the view inherits.
    @ViewBuilder
    public func foregroundStyle<S>(_ style: S?) -> some View where S: ShapeStyle {
        if let style {
            self.foregroundStyle(style)
        } else {
            self
        }
    }
}
