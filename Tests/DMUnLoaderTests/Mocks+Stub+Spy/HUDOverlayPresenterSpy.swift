//
//  DMUnLoader
//
//  Created by Mykola Dementiev
//

import DMUnLoader

/// Records the loading managers whose HUD a lifecycle asks to present, in order.
@MainActor
final class HUDOverlayPresenterSpy: HUDOverlayPresenting {
    private(set) var presented: [AnyObject] = []

    func present<LM: DMLoadingManager>(_ loadingManager: LM) {
        presented.append(loadingManager)
    }
}
