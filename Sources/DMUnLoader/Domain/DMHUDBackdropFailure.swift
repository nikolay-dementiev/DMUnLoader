//
//  DMUnLoader
//
//  Created by Mykola Dementiev
//

/// Why the backdrop of the HUD could not draw the variable blur it was asked for.
///
/// When this happens the backdrop shows the plain blur of the system over the whole screen
/// instead. The HUD itself is not affected: its state, its buttons and the way it leaves the
/// screen stay as they are. A host learns the reason through
/// ``DMLoadingManagerSettings/onBackdropFailure``.
///
/// A new case arrives only in a major version.
public enum DMHUDBackdropFailure: Error, Sendable, Equatable {
    /// The system on this device does not offer the variable blur, or did not accept it.
    case effectUnavailable

    /// The image that shapes the blur could not be created.
    case maskCreationFailed

    /// A value of the blur was not valid. The HUD gives the blur values that are valid, so
    /// the HUD itself does not cause this.
    case invalidConfiguration
}
