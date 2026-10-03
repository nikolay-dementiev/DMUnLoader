//
//  DMUnLoader
//
//  Created by Mykola Dementiev
//

import UIKit
import XCTest
import DMUnLoader

/// The level of the HUD window, as the settings of a loading manager give it.
final class HUDWindowLevelSettingsTests: XCTestCase {

    func test_settings_withOnlyTheDelay_getTheNormalLevel() {
        XCTAssertEqual(
            DelayOnlySettings().hudWindowLevel,
            .normal,
            "a settings type that sets only the delay keeps the level before 1.1.0"
        )
    }

    func test_defaultSettings_storeTheirLevel() {
        XCTAssertEqual(DMLoadingManagerDefaultSettings().hudWindowLevel, .normal, "the default settings keep the normal level")
        XCTAssertEqual(
            DMLoadingManagerDefaultSettings(hudWindowLevel: .normal + 1).hudWindowLevel,
            .normal + 1,
            "the default settings keep the given level"
        )
    }
}

private struct DelayOnlySettings: DMLoadingManagerSettings {
    let autoHideDelay: Duration = .seconds(2)
}
