//
//  DMUnLoader
//
//  Created by Mykola Dementiev
//

/// Stands for the content a HUD shows, without saying what that content is. Two tokens are equal
/// exactly when the content they stand for did not change in between, so a holder that compares them
/// knows whether the content changed and keeps nothing of the content itself.
///
/// Whoever makes tokens decides what "changed" means, and gives the same revision to the same content.
package struct HUDContentToken: Equatable, Sendable {
    private let revision: Int

    package init(revision: Int) {
        self.revision = revision
    }
}
