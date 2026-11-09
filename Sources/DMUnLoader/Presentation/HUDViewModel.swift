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

/// Reads its HUD model on every access and acts through it: the state stays where its owner keeps
/// it, and the view model keeps no copy of it.
@MainActor
package struct DefaultHUDViewModel: HUDViewModel {
    private let model: any HUDModel

    package init(model: any HUDModel) {
        self.model = model
    }

    package var showsHUD: Bool {
        model.phase.showsHUD
    }

    package func cardTapped() {
        hide(onTapAt: .card)
    }

    @discardableResult
    package func backdropTapped() -> Bool {
        hide(onTapAt: .backdrop)
    }

    package func closeTapped() {
        model.hide()
    }

    /// Hides the HUD when the rules of the model let a tap at `target` hide the kind shown, and
    /// returns whether the HUD is gone after the call: a `hide()` that keeps the state does not
    /// count as a hide.
    @discardableResult
    private func hide(onTapAt target: HUDTapTarget) -> Bool {
        let phase = model.phase
        guard DismissPolicy.tapDismisses(phase, on: target, rules: model.dismissalRules) else {
            return false
        }
        model.hide()
        return !model.phase.showsHUD
    }
}
