import DMUnLoader
import SwiftUI
import UIKit

/// Settings a host writes to choose how each kind of HUD leaves the screen, the level of the
/// HUD window and what the HUD draws behind its card.
struct HUDOptionsSettings: DMLoadingManagerSettings {
    let autoHideDelay: Duration = .seconds(3)
    let hudDismissal = DMHUDDismissalRules(
        success: DMHUDDismissal(autoHide: .after(.seconds(1))),
        failureWithoutRetry: DMHUDDismissal(cardTapHides: false),
        failureWithRetry: DMHUDDismissal(autoHide: .never, cardTapHides: false, backdropTapHides: false)
    )
    let hudWindowLevel: UIWindow.Level = .alert + 1
    let backdrop: DMHUDBackdrop = .material(.thinMaterial)
}

/// The same options through the default settings. The values need no actor, so a host can
/// build them anywhere; only the loading manager lives on the main actor.
enum HUDOptionsUsage {
    static let backdrops: [DMHUDBackdrop] = [.variableBlur, .dim(), .dim(.red.opacity(0.3)), .material(), .clear]

    static func makeSettings(backdrop: DMHUDBackdrop) -> DMLoadingManagerDefaultSettings {
        DMLoadingManagerDefaultSettings(
            autoHideDelay: .seconds(2),
            hudDismissal: DMHUDDismissalRules(failureWithRetry: DMHUDDismissal(autoHide: .never)),
            hudWindowLevel: .normal + 1,
            backdrop: backdrop
        )
    }

    @MainActor
    static func makeManagers() -> [DMLoadingManagerMain] {
        [DMLoadingManagerMain(state: .none, settings: HUDOptionsSettings())]
            + backdrops.map { DMLoadingManagerMain(state: .none, settings: makeSettings(backdrop: $0)) }
    }
}
