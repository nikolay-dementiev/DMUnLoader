import DMUnLoader

/// The default settings of a loading manager, and a failure shown without Retry through the
/// protocol: what generic host code writes.
@MainActor
enum DefaultSettingsUsage {
    static func makeManager() -> DMLoadingManagerMain {
        DMLoadingManagerMain(state: .none, settings: DMLoadingManagerDefaultSettings(autoHideDelay: .seconds(4)))
    }

    static func showFailure<LM: DMLoadingManager>(on manager: LM, error: any Error) {
        manager.showFailure(error, provider: DefaultDMLoadingViewProvider())
    }
}
