//
//  DMUnLoader
//
//  Created by Mykola Dementiev
//

import SwiftUI

extension View {
    @ViewBuilder
    public func foregroundStyle<S>(_ style: S?) -> some View where S: ShapeStyle {
        if let style {
            self.foregroundStyle(style)
        } else {
            self
        }
    }
}
