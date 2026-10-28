//
//  DMUnLoader
//
//  Created by Mykola Dementiev
//

import UIKit
import XCTest
import DMUnLoader

/// The handler of the backdrop failure in the settings of a loading manager: what carries it, and that
/// a host that does not set one keeps the settings it had.
@MainActor
final class HUDBackdropFailureSettingsTests: XCTestCase {

    func test_defaultSettings_newInitializer_carriesTheHandler() {
        let spy = BackdropFailureSpy()

        let sut = DMLoadingManagerDefaultSettings(onBackdropFailure: { spy.record($0) })

        sut.onBackdropFailure?(.maskCreationFailed)
        XCTAssertEqual(spy.received, [.maskCreationFailed], "the settings hand the host the handler it gave them")
    }

    func test_defaultSettings_existingInitializer_hasNoHandler() {
        XCTAssertNil(DMLoadingManagerDefaultSettings().onBackdropFailure, "no argument, no handler")
        XCTAssertNil(
            DMLoadingManagerDefaultSettings(autoHideDelay: .seconds(4), backdrop: .clear).onBackdropFailure,
            "the arguments of before 1.2.0 give no handler"
        )
    }

    func test_defaultSettings_newInitializer_repeatsTheDefaultsOfTheExistingOne() {
        let existing = DMLoadingManagerDefaultSettings()

        let sut = DMLoadingManagerDefaultSettings(onBackdropFailure: nil)

        XCTAssertEqual(sut.autoHideDelay, existing.autoHideDelay, "the same auto-hide delay")
        XCTAssertEqual(sut.hudDismissal, existing.hudDismissal, "the same dismissal rules")
        XCTAssertEqual(sut.hudWindowLevel, existing.hudWindowLevel, "the same window level")
        let drawing = sut.backdrop.drawing(reducesTransparency: false)
        XCTAssertEqual(drawing.dim, existing.backdrop.drawing(reducesTransparency: false).dim, "the same dim")
        XCTAssertTrue(isVariableBlur(drawing.layer), "the same backdrop, the variable blur: \(drawing.layer)")
    }

    func test_settingsOfVersion110_compileUnchanged_andHaveNoHandler() {
        let sut = SettingsOfVersion110()

        XCTAssertNil(sut.onBackdropFailure, "settings that never heard of the requirement have none")
    }

    // MARK: - Helpers

    private func isVariableBlur(_ layer: HUDBackdropDrawing.Layer) -> Bool {
        if case .variableBlur = layer {
            return true
        }
        return false
    }
}

/// Settings written against 1.1.0: the four requirements it had and nothing else.
private struct SettingsOfVersion110: DMLoadingManagerSettings {
    let autoHideDelay: Duration = .seconds(2)
    let hudDismissal = DMHUDDismissalRules()
    let hudWindowLevel: UIWindow.Level = .normal
    let backdrop: DMHUDBackdrop = .variableBlur
}
