//
//  DMUnLoader
//
//  Created by Mykola Dementiev
//

import Foundation
import os

/// The default texts of the HUD from the library's string catalog, in the language of the app.
/// A key or a table that is missing gives the English text, and so does a missing bundle.
package struct BundleHUDTexts: HUDTexts {
    private let bundle: Bundle?

    /// - Parameter bundle: The bundle that holds the catalog; `nil` shows the English texts.
    package init(bundle: Bundle? = BundleHUDTexts.libraryBundle) {
        self.bundle = bundle
    }

    package func text(for role: HUDDefaultText) -> String {
        bundle?.localizedString(forKey: role.key, value: role.english, table: "Localizable") ?? role.english
    }

    /// The resource bundle of the library, where SwiftPM and CocoaPods put it. Unlike the
    /// generated `Bundle.module`, which stops the app when the bundle is missing, a missing
    /// bundle is logged once and the HUD shows its English texts.
    package static let libraryBundle: Bundle? = {
        let names = ["DMUnLoader_DMUnLoader.bundle", "DMUnLoader.bundle"]
        let places = [Bundle.main.resourceURL, Bundle(for: BundleFinder.self).resourceURL, Bundle.main.bundleURL]
        for place in places.compactMap({ $0 }) {
            for name in names {
                if let bundle = Bundle(url: place.appendingPathComponent(name)) {
                    return bundle
                }
            }
        }
        Logger(subsystem: "DMUnLoader", category: "texts")
            .fault("The resource bundle of DMUnLoader is missing; the HUD shows its English texts.")
        return nil
    }()
}

/// Finds the binary of the library, whose resources the resource bundle may sit in.
private final class BundleFinder {}
