//
//  DMUnLoader
//
//  Created by Mykola Dementiev
//

import DMUnLoader
import XCTest

/// A loading manager and a view provider are objects: each is equal only to itself. A host
/// can give its provider a hash of its own, so the provider pair with colliding hashes is the
/// one that failed while equality compared hashes; the manager is final and pinned as is.
@MainActor
final class IdentityEqualityTests: XCTestCase {

    func test_manager_comparedWithItself_isEqual() {
        let manager = DMLoadingManagerMain()

        XCTAssertEqual(manager, manager, "a manager is equal to itself")
    }

    func test_manager_twoInstances_areNotEqual() {
        XCTAssertNotEqual(DMLoadingManagerMain(), DMLoadingManagerMain(), "two managers are two objects")
    }

    func test_provider_comparedWithItself_isEqual() {
        let provider = CollidingHashProvider()

        XCTAssertEqual(provider, provider, "a provider is equal to itself")
    }

    func test_provider_twoInstancesWhoseHashesCollide_areNotEqual() {
        XCTAssertNotEqual(
            CollidingHashProvider(),
            CollidingHashProvider(),
            "two providers are two objects, even when their hashes collide"
        )
    }
}

/// A provider whose instances all have the same hash, as unequal values may.
private final class CollidingHashProvider: DMLoadingViewProvider {
    func hash(into hasher: inout Hasher) {
        hasher.combine(0)
    }
}
