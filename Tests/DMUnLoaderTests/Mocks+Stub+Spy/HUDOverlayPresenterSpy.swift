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

    private(set) var dismissCount = 0

    func present<LM: DMLoadingManager>(_ loadingManager: LM) {
        presented.append(loadingManager)
    }

    func dismiss() {
        dismissCount += 1
    }
}
