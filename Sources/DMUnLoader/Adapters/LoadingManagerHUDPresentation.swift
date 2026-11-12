//
//  DMUnLoader
//
//  Created by Mykola Dementiev
//

extension HUDPresentation where Content == HUDComposition {
    /// The HUD of `loadingManager`: its identity, and the composition that shows it, made here
    /// where the type of the manager is known. The composition holds the manager strongly, so a
    /// manager that only the HUD refers to stays alive until the value is replaced or removed. It
    /// reads nothing of the manager now: what the presenter needs is read when it asks.
    package init<LM: DMLoadingManager>(_ loadingManager: LM) {
        self.init(id: ObjectIdentifier(loadingManager), content: HUDComposition(loadingManager))
    }
}

extension HUDOverlayLifecycle where Content == HUDComposition {
    /// The loading manager of the scene was set, to `loadingManager`. The same manager again
    /// keeps its HUD; another one replaces it; `nil` removes it.
    package func loadingManagerDidChange<LM: DMLoadingManager>(to loadingManager: LM?) {
        presentationDidChange(to: loadingManager.map { HUDPresentation($0) })
    }
}

extension RootViewHUDAttachment where Content == HUDComposition {
    /// The root view was given `loadingManager`. Its HUD is shown over the scene of the view,
    /// now or once the view is in one; another manager takes over the HUD.
    package func loadingManagerDidChange<LM: DMLoadingManager>(to loadingManager: LM) {
        presentationDidChange(to: HUDPresentation(loadingManager))
    }
}
