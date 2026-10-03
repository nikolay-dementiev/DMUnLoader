import DMUnLoader

/// Settings of a loading manager, with the delay and the dismissal rules chosen by the host.
struct ExampleLoadingSettings: DMLoadingManagerSettings {
    let autoHideDelay: Duration
    var hudDismissal = DMHUDDismissalRules()
}
