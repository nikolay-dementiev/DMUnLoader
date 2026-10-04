//
//  DMUnLoader
//
//  Created by Mykola Dementiev
//

import SwiftUI

extension EdgeInsets: @retroactive Hashable {
    /// Hashes the four insets, which `==` compares.
    public func hash(into hasher: inout Hasher) {
        hasher.combine(top)
        hasher.combine(leading)
        hasher.combine(bottom)
        hasher.combine(trailing)
    }
}
