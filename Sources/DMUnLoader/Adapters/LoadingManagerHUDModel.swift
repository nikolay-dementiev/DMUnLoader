//
//  DMUnLoader
//
//  Created by Mykola Dementiev
//

/// The HUD model of a loading manager. It reads the manager on every access and keeps no copy of
/// what it reads, so the manager's state stays the one state.
///
/// It holds the manager strongly: whoever holds the model holds the manager. A holder that must not
/// keep a manager alive makes the model when it needs one, from a manager it holds weakly.
@MainActor
package struct LoadingManagerHUDModel<LM: DMLoadingManager>: HUDModel {
    private let loadingManager: LM

    package init(_ loadingManager: LM) {
        self.loadingManager = loadingManager
    }

    package var phase: HUDPhase {
        loadingManager.loadableState.phase
    }

    package var dismissalRules: DMHUDDismissalRules {
        loadingManager.settings.hudDismissal
    }

    package func hide() {
        loadingManager.hide()
    }
}
