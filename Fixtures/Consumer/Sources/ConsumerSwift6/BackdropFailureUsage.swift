import DMUnLoader

/// Settings a host writes to be told when the backdrop of the HUD lost its blur.
struct BackdropFailureSettings: DMLoadingManagerSettings {
    let autoHideDelay: Duration = .seconds(2)
    let onBackdropFailure: (@MainActor @Sendable (DMHUDBackdropFailure) -> Void)?
}

/// The handler through the default settings, and what a host does with the failure it is told.
enum BackdropFailureUsage {
    @MainActor
    static func makeManager(
        onFailure: @escaping @MainActor @Sendable (DMHUDBackdropFailure) -> Void
    ) -> DMLoadingManagerMain {
        DMLoadingManagerMain(
            state: .none,
            settings: DMLoadingManagerDefaultSettings(backdrop: .variableBlur, onBackdropFailure: onFailure)
        )
    }

    @MainActor
    static func makeManagerOfItsOwnSettings(
        onFailure: @escaping @MainActor @Sendable (DMHUDBackdropFailure) -> Void
    ) -> DMLoadingManagerMain {
        DMLoadingManagerMain(state: .none, settings: BackdropFailureSettings(onBackdropFailure: onFailure))
    }

    static func describe(_ failure: DMHUDBackdropFailure) -> String {
        switch failure {
        case .effectUnavailable:
            "The system does not offer the variable blur."
        case .maskCreationFailed:
            "The image that shapes the blur could not be created."
        case .invalidConfiguration:
            "A value of the blur was not valid."
        }
    }
}
