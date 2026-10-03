import DMUnLoader
import UIKit

/// Settings of a loading manager, with the delay, the dismissal rules and the level of the
/// HUD window chosen by the host.
struct ExampleLoadingSettings: DMLoadingManagerSettings {
    let autoHideDelay: Duration
    var hudDismissal = DMHUDDismissalRules()
    var hudWindowLevel: UIWindow.Level = .normal
}
