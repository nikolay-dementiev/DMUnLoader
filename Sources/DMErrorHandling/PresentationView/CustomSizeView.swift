//
//  DMErrorHandling
//
//  Created by Mykola Dementiev
//

import SwiftUICore

public struct CustomSizeView {
    public init(width: CGFloat,
                height: CGFloat,
                alignment: Alignment = .center) {
        self.width = width
        self.height = height
        self.alignment = alignment
    }
    
    var width: CGFloat?
    var height: CGFloat?
    var alignment: Alignment = .center
}
