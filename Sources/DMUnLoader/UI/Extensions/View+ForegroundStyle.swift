//
//  DMUnLoader
//
//  Created by Mykola Dementiev
//

import SwiftUI

extension View {
    /// Sets the foreground style to `style`, or leaves the view as it is when `style` is `nil`.
    @ViewBuilder
    public func foregroundStyle<S>(_ style: S?) -> some View where S: ShapeStyle {
        if let style {
            self.foregroundStyle(style)
        } else {
            self
        }
    }
}
