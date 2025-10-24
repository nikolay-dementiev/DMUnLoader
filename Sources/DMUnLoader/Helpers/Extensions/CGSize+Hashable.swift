//
//  DMUnLoader
//
//  Created by Mykola Dementiev
//

import SwiftUI

@available(iOS, obsoleted: 18.0, message: "CGSize conforms to Hashable in iOS 18 and later")
extension CGSize: @retroactive Hashable {
    public func hash(into hasher: inout Hasher) {
        hasher.combine(width)
        hasher.combine(height)
    }
}
