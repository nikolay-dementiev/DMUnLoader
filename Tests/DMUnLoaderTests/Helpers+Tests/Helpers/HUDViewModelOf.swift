//
//  DMUnLoader
//
//  Created by Mykola Dementiev
//

import DMUnLoader

/// The view model of the HUD built the way `HUDComposition` builds it: over `manager`, reading it on every access.
/// It does not call the composition, so a change to that wiring has to be made here too.
@MainActor
func hudViewModel<LM: DMLoadingManager>(of manager: LM) -> any HUDViewModel {
    DefaultHUDViewModel(model: LoadingManagerHUDModel(manager))
}
