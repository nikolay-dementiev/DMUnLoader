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

    /// A tap on the card of the HUD, outside its buttons.
    func cardTapped()

    /// A tap outside the card. Returns whether the HUD went, for an accessibility escape that
    /// does what this tap does.
    @discardableResult
    func backdropTapped() -> Bool

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

    package func cardTapped() {
        hide(onTapAt: .card)
    }

    @discardableResult
    package func backdropTapped() -> Bool {
        hide(onTapAt: .backdrop)
    }

    package func closeTapped() {
        loadingManager.hide()
    }

    /// Hides the HUD when the rules of the manager's settings let a tap at `target` hide the
    /// kind shown, and returns whether the HUD is gone after the call: a manager's `hide()` that
    /// keeps its state does not count as a hide.
    @discardableResult
    private func hide(onTapAt target: HUDTapTarget) -> Bool {
        let phase = loadingManager.loadableState.phase
        guard DismissPolicy.tapDismisses(phase, on: target, rules: loadingManager.settings.hudDismissal) else {
            return false
        }
        loadingManager.hide()
        return !loadingManager.loadableState.showsHUD
    }
}
