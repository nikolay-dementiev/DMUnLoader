//
//  DMUnLoader
//
//  Created by Mykola Dementiev
//

extension HUDPresentation {
    /// The HUD of `loadingManager`, with its type kept for the presenter. The value holds the
    /// manager strongly, as the lifecycle always has.
    fileprivate init<LM: DMLoadingManager>(_ loadingManager: LM) {
        self.init(id: ObjectIdentifier(loadingManager)) { presenter in
            presenter.present(loadingManager)
        }
    }
}

extension HUDOverlayLifecycle {
    /// The loading manager of the scene was set, to `loadingManager`. The same manager again
    /// keeps its HUD; another one replaces it; `nil` removes it.
    package func loadingManagerDidChange<LM: DMLoadingManager>(to loadingManager: LM?) {
        presentationDidChange(to: loadingManager.map(HUDPresentation.init))
    }
}

extension RootViewHUDAttachment {
    /// The root view was given `loadingManager`. Its HUD is shown over the scene of the view,
    /// now or once the view is in one; another manager takes over the HUD.
    package func loadingManagerDidChange<LM: DMLoadingManager>(to loadingManager: LM) {
        presentationDidChange(to: HUDPresentation(loadingManager))
    }
}
