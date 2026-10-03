//
//  DMUnLoader
//
//  Created by Mykola Dementiev
//

/// A default text of the HUD that the library's string catalog translates.
package enum HUDDefaultText: CaseIterable, Sendable {
    case failureTitle
    case failureClose
    case failureRetry
    case loadingText

    /// The key of the text in the catalog.
    package var key: String {
        switch self {
        case .failureTitle:
            "hud.failure.title"
        case .failureClose:
            "hud.failure.close"
        case .failureRetry:
            "hud.failure.retry"
        case .loadingText:
            "hud.loading.text"
        }
    }

    /// The English text: the default of the settings, and the text shown whenever the catalog
    /// has no other.
    package var english: String {
        switch self {
        case .failureTitle:
            "An error has occurred!"
        case .failureClose:
            "Close"
        case .failureRetry:
            "Retry"
        case .loadingText:
            "Loading..."
        }
    }

    /// The text to show for `text`, set for this role. The library's English default is looked
    /// up in `texts`; any other text is the host's and is shown as given.
    package func displayed(_ text: String, using texts: any HUDTexts) -> String {
        text == english ? texts.text(for: self) : text
    }
}

/// The default texts of the HUD in the language of the app.
package protocol HUDTexts: Sendable {
    /// The text for `role`.
    func text(for role: HUDDefaultText) -> String
}
