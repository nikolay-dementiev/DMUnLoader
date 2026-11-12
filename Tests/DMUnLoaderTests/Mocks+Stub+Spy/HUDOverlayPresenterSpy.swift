//
//  DMUnLoader
//
//  Created by Mykola Dementiev
//

import DMUnLoader

/// Records the presentations whose HUD a lifecycle asks to present, in order. It keeps each one, so a
/// manager that a presentation holds stays alive for as long as the spy does.
@MainActor
final class HUDOverlayPresenterSpy: HUDOverlayPresenting {
    typealias Content = HUDComposition

    private(set) var presentations: [HUDPresentation<HUDComposition>] = []

    private(set) var dismissCount = 0

    /// The identities of the presentations, in order: those of the managers that were presented.
    var presentedIDs: [ObjectIdentifier] {
        presentations.map(\.id)
    }

    func present(_ presentation: HUDPresentation<HUDComposition>) {
        presentations.append(presentation)
    }

    func dismiss() {
        dismissCount += 1
    }
}
