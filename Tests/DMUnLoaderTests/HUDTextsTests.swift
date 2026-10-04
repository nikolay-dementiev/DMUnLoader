//
//  DMUnLoader
//
//  Created by Mykola Dementiev
//

import XCTest
import DMUnLoader

/// The library's default texts come from its string catalog, in English only for now, and
/// fall back to the English literal whenever the catalog cannot be read.
final class HUDTextsTests: XCTestCase {

    func test_defaultTexts_englishLookup_equalsTheReleasedDefaults() {
        let errorSettings = DMErrorDefaultViewSettings()

        for role in HUDDefaultText.allCases {
            XCTAssertEqual(BundleHUDTexts().text(for: role), role.english, "\(role) reads its English text from the catalog")
        }
        XCTAssertEqual(errorSettings.errorText, HUDDefaultText.failureTitle.english, "the default title is the catalogued one")
        XCTAssertEqual(
            errorSettings.actionButtonCloseSettings.text,
            HUDDefaultText.failureClose.english,
            "the default Close text is the catalogued one"
        )
        XCTAssertEqual(
            errorSettings.actionButtonRetrySettings.text,
            HUDDefaultText.failureRetry.english,
            "the default Retry text is the catalogued one"
        )
        XCTAssertEqual(
            ProgressTextProperties().text,
            HUDDefaultText.loadingText.english,
            "the default loading text is the catalogued one"
        )
    }

    func test_libraryBundle_holdsTheCatalogInEnglish() throws {
        let bundle = try XCTUnwrap(BundleHUDTexts.libraryBundle, "the resource bundle of the library is found")

        for role in HUDDefaultText.allCases {
            XCTAssertEqual(
                bundle.localizedString(forKey: role.key, value: "<missing>", table: "Localizable"),
                role.english,
                "the table holds \(role.key) in English"
            )
        }
    }

    func test_bundleHUDTexts_withoutBundle_returnsTheEnglishText() {
        let texts = BundleHUDTexts(bundle: nil)

        for role in HUDDefaultText.allCases {
            XCTAssertEqual(texts.text(for: role), role.english, "without a bundle \(role) is its English text")
        }
    }
}
