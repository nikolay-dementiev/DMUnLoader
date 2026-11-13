//
//  DMUnLoader
//
//  Created by Mykola Dementiev
//

import CoreGraphics

@available(iOS, obsoleted: 18.0, message: "CGSize conforms to Hashable in iOS 18 and later")
extension CGSize: @retroactive Hashable {
    /// Hashes the width and the height, which `==` compares.
    ///
    /// Retired: the conformance of `CGSize` to `Hashable` is removed in 2.0.0. It conforms a type
    /// of the system to a protocol of the system for every app that imports DMUnLoader, and
    /// another module can declare the same conformance. iOS 18 and later provide it. For a set or
    /// a dictionary key, use a type of your own that holds the width and the height.
    public func hash(into hasher: inout Hasher) {
        hasher.combine(width)
        hasher.combine(height)
    }
}
