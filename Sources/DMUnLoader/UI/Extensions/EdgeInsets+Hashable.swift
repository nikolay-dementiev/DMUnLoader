//
//  DMUnLoader
//
//  Created by Mykola Dementiev
//

import SwiftUI

extension EdgeInsets: @retroactive Hashable {
    /// Hashes the four insets, which `==` compares.
    ///
    /// Retired: the conformance of `EdgeInsets` to `Hashable` is removed in 2.0.0. It conforms a
    /// type of the system to a protocol of the system for every app that imports DMUnLoader, and
    /// another module can declare the same conformance. For a set or a dictionary key, use a type
    /// of your own that holds the four insets.
    public func hash(into hasher: inout Hasher) {
        hasher.combine(top)
        hasher.combine(leading)
        hasher.combine(bottom)
        hasher.combine(trailing)
    }
}
