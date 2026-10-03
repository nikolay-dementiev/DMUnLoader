//
//  DMUnLoader
//
//  Created by Mykola Dementiev
//

/// What the HUD view shows and what its touches do.
@MainActor
package protocol HUDViewModel {
    /// Whether a HUD is shown: the backdrop, the card and the blur behind them.
    var showsHUD: Bool { get }

    /// A tap on the HUD, outside its buttons.
    func tapped()

    /// The Close button of a failure.
    func closeTapped()
}

/// Reads its loading manager on every access and acts through it: the manager's state stays
/// the one state, and the view model keeps no copy of it.
@MainActor
package struct DefaultHUDViewModel<LM: DMLoadingManager>: HUDViewModel {
    private let loadingManager: LM

    package init(loadingManager: LM) {
        self.loadingManager = loadingManager
    }

    package var showsHUD: Bool {
        loadingManager.loadableState.showsHUD
    }

    package func tapped() {
        if DismissPolicy.tapDismisses(loadingManager.loadableState.phase) {
            loadingManager.hide()
        }
    }

    package func closeTapped() {
        loadingManager.hide()
    }
}
