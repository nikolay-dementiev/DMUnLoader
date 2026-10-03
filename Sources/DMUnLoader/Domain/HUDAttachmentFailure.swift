//
//  DMUnLoader
//
//  Created by Mykola Dementiev
//

/// Why the HUD of a `DMRootLoadingView` cannot be shown over its scene.
///
/// `DMRootLoadingView(manager:content:onAttachmentFailure:)` passes a value of this type to its
/// `onAttachmentFailure` closure. This version knows no such reason, so no value exists and the
/// closure is never called. A window that belongs to no scene appears on no screen, and SwiftUI
/// does not put the view into it, so the view cannot learn of that window: neither the view nor
/// its HUD appears. Later versions may add reasons as static members; compare a value with them
/// using `==`.
public struct DMHUDAttachmentFailure: Error, Hashable, Sendable, CustomStringConvertible {
    private enum Reason: Hashable, Sendable {}

    private let reason: Reason

    /// What went wrong, in one English sentence, for logs. Not meant for the user.
    public var description: String {
        switch reason {}
    }
}
