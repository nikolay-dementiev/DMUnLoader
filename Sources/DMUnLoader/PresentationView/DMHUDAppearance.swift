//
//  DMUnLoader
//
//  Created by Mykola Dementiev
//

import SwiftUI
import UIKit

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
        switch kind {
        case .standard:
            return DMProgressViewDefaultSettings()
        case .accessible:
            return DMProgressViewDefaultSettings(
                loadingTextProperties: ProgressTextProperties(foregroundColor: Palette.ink, lineLimit: nil),
                progressIndicatorProperties: ProgressIndicatorProperties(size: .large, tintColor: Palette.ink)
            )
        }
    }

    /// The settings of the library's error view in this look.
    package var errorViewSettings: any DMErrorViewSettings {
        switch kind {
        case .standard:
            return DMErrorDefaultViewSettings()
        case .accessible:
            return DMErrorDefaultViewSettings(
                actionButtonCloseSettings: buttonSettings(text: "Close"),
                actionButtonRetrySettings: buttonSettings(text: "Retry"),
                errorTextSettings: ErrorTextSettings(foregroundColor: Palette.ink),
                errorImageSettings: ErrorImageSettings(
                    image: Image(systemName: "exclamationmark.triangle"),
                    foregroundColor: Palette.errorIcon
                )
            )
        }
    }

    /// The colour of the label and of the outline of the Close and Retry buttons.
    package var buttonColor: Color {
        switch kind {
        case .standard:
            return .white
        case .accessible:
            return Palette.ink
        }
    }

    private func buttonSettings(text: String) -> ActionButtonSettings {
        let color = buttonColor
        return ActionButtonSettings(text: text) { @MainActor in
            AnyButtonStyle(DMHudButtonStyle(color: color))
        }
    }

    /// The settings of the library's success view in this look.
    package var successViewSettings: any DMSuccessViewSettings {
        switch kind {
        case .standard:
            return DMSuccessDefaultViewSettings()
        case .accessible:
            return DMSuccessDefaultViewSettings(
                successImageProperties: SuccessImageProperties(foregroundColor: Palette.successIcon),
                successTextProperties: SuccessTextProperties(foregroundColor: Palette.ink)
            )
        }
    }

    /// The fill of the card. The standard look keeps the gray of every release so far, decided by
    /// `HUDCardStyle`. The accessible look is opaque whether the card is shown or fading in.
    package func cardBackground(isShown: Bool, reducesTransparency: Bool) -> Color {
        switch kind {
        case .standard:
            return Color.gray.opacity(
                HUDCardStyle.backgroundOpacity(isShown: isShown, reducesTransparency: reducesTransparency)
            )
        case .accessible:
            return Palette.card
        }
    }
}

/// The colours of the accessible look, all of the system or dynamic in light and in dark mode. Their
/// ratios are measured by the tests, not argued here: every text reaches 4.5 to 1 against the card
/// and every icon, indicator and outline 3 to 1.
private enum Palette {
    /// Text, indicator and button: the label colour, black on white or white on black.
    static let ink = Color(UIColor.label)

    /// The card: the secondary background of the system, opaque.
    static let card = Color(UIColor.secondarySystemBackground)

    /// A red darker than the system red where the card is light, so that it reaches 4.5 to 1 on it, which
    /// the accessibility audit of Xcode asks of the default image.
    static let errorIcon = dynamic(
        light: UIColor(red: 215.0 / 255, green: 0, blue: 21.0 / 255, alpha: 1),
        dark: UIColor(red: 1, green: 69.0 / 255, blue: 58.0 / 255, alpha: 1)
    )

    /// A green darker than the system green where the card is light, for the same reason.
    static let successIcon = dynamic(
        light: UIColor(red: 28.0 / 255, green: 120.0 / 255, blue: 50.0 / 255, alpha: 1),
        dark: UIColor(red: 48.0 / 255, green: 209.0 / 255, blue: 88.0 / 255, alpha: 1)
    )

    private static func dynamic(light: UIColor, dark: UIColor) -> Color {
        Color(UIColor { $0.userInterfaceStyle == .dark ? dark : light })
    }
}
