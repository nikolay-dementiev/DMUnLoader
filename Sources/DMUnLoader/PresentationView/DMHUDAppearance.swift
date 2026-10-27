//
//  DMUnLoader
//
//  Created by Mykola Dementiev
//

import SwiftUI

/// How the HUD looks: the card it draws and the colours and layout of the library's own views.
///
/// A provider chooses it with `DMLoadingViewProvider.hudAppearance`, and the HUD draws the state
/// of that provider with it. ``standard`` is the default everywhere, so an app that does nothing
/// keeps the look it has; ``accessible`` is an opt-in.
public struct DMHUDAppearance: Hashable, Sendable {
    package enum Kind: Hashable, Sendable {
        case standard
        case accessible
    }

    package let kind: Kind

    private init(kind: Kind) {
        self.kind = kind
    }

    /// The look of every release so far, and the default: white text on a gray card of opacity
    /// 0.8, which is opaque under Reduce Transparency, and a loading view that takes at most
    /// half of its `frameGeometrySize`.
    ///
    /// That look does not reach a contrast of 4.5:1 and cuts the loading text at large
    /// accessibility text sizes, which the README lists as known issues. It stays as it is so
    /// that no screen of an app changes with an update; use ``accessible`` where those matter.
    public static let standard = DMHUDAppearance(kind: .standard)

    /// An opt-in look of the library's own views that reaches the contrast of the Web Content
    /// Accessibility Guidelines and keeps its text visible at the largest text sizes:
    /// - every text against its background at 4.5:1 or more, in light and in dark mode;
    /// - every icon, progress indicator and button outline against its background at 3:1 or more;
    /// - an opaque card, in the colours of the system, that follows light and dark mode and the
    ///   system's Increase Contrast;
    /// - no cap on the size of the loading view: its text wraps at the width of the screen and
    ///   shows in full at every text size, and a card taller than the screen scrolls;
    /// - the Close and Retry buttons stack at accessibility text sizes.
    ///
    /// These guarantees cover the library's own views. A provider of your own that returns this
    /// look from `hudAppearance` gets the card; its own views keep the colours they have.
    public static let accessible = DMHUDAppearance(kind: .accessible)
}

extension DMHUDAppearance {
    /// The settings of the library's loading view in this look.
    package var loadingViewSettings: any DMProgressViewSettings {
        DMProgressViewDefaultSettings()
    }

    /// The settings of the library's error view in this look.
    package var errorViewSettings: any DMErrorViewSettings {
        DMErrorDefaultViewSettings()
    }

    /// The settings of the library's success view in this look.
    package var successViewSettings: any DMSuccessViewSettings {
        DMSuccessDefaultViewSettings()
    }

    /// The fill of the card: the gray of every release so far, decided by `HUDCardStyle`.
    package func cardBackground(isShown: Bool, reducesTransparency: Bool) -> Color {
        Color.gray.opacity(
            HUDCardStyle.backgroundOpacity(isShown: isShown, reducesTransparency: reducesTransparency)
        )
    }
}
