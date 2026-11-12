//
//  DMUnLoader
//
//  Created by Mykola Dementiev
//

import UIKit
import XCTest
import DMUnLoader

/// The composition of one loading manager with no window: what a window takes from it.
@MainActor
final class HUDCompositionTests: XCTestCase {

    // MARK: - The escape

    func test_escape_afterTheManagerIsGone_reportsThatNothingWentAndKeepsNoManagerAlive() {
        var manager: HostLoadingManagerSpy? = HostLoadingManagerSpy(loadableState: Self.success)
        let isReleased = { [weak first = manager] in first == nil }
        var composition: HUDComposition? = manager.map { HUDComposition($0) }
        guard let escape = composition?.escape else {
            XCTFail("A composition made from a manager has an escape.")
            return
        }
        // A window keeps the escape and nothing else of the composition.
        composition = nil
        manager = nil

        XCTAssertTrue(isReleased(), "the escape held the manager that the composition was made from")
        XCTAssertFalse(escape(), "the escape of a manager that is gone reports that nothing went")
    }

    func test_escape_onASuccess_asksForAHideAndReportsThatItWent() {
        let manager = HostLoadingManagerSpy(loadableState: Self.success, hideClearsState: true)
        let sut = makeSUT(manager)

        let went = sut.escape()

        XCTAssertEqual(manager.hideCount, 1, "the escape asks the manager for a hide")
        XCTAssertTrue(went, "the success is gone after the call, so the escape reports that it went")
    }

    // MARK: - What is read when

    func test_showsHUD_readsTheManagerWhenAsked_notWhenTheCompositionWasMade() {
        let manager = HostLoadingManagerSpy(loadableState: .none)
        let sut = makeSUT(manager)
        XCTAssertFalse(sut.showsHUD, "nothing is shown by a manager in the none state")

        manager.set(Self.success)

        XCTAssertTrue(sut.showsHUD, "the composition read the state of the moment it was asked, not the one it was made in")
    }

    func test_windowLevel_readsTheSettingsWhenAsked_notWhenTheCompositionWasMade() {
        let manager = HostLoadingManagerSpy(settings: Self.settings(level: .normal))
        let sut = makeSUT(manager)
        XCTAssertEqual(sut.windowLevel, .normal, "the level of the settings the manager was made with")

        manager.replaceSettings(with: Self.settings(level: .alert))

        XCTAssertEqual(sut.windowLevel, .alert, "the composition read the settings of the moment it was asked")
    }

    // MARK: - What the composition holds

    func test_composition_afterTheCallerLetGoOfTheManager_stillReadsIt() {
        var manager: HostLoadingManagerSpy? = HostLoadingManagerSpy(
            loadableState: Self.success,
            settings: DMLoadingManagerDefaultSettings(autoHideDelay: .seconds(600), hudWindowLevel: .alert)
        )
        let isReleased = { [weak held = manager] in held == nil }
        var sut: HUDComposition? = manager.map { HUDComposition($0) }

        // Once the caller lets go, nothing but the composition holds the manager, as when a lifecycle
        // keeps the composition of a manager that was set before its scene connected.
        manager = nil

        XCTAssertFalse(isReleased(), "the composition holds the manager that it was made from")
        XCTAssertEqual(sut?.showsHUD, true, "the composition still reads the state of the manager that nothing else holds")
        XCTAssertEqual(sut?.windowLevel, .alert, "the composition still reads the settings of that manager")
        sut = nil
        XCTAssertTrue(isReleased(), "the composition is the only holder: the manager goes with it")
    }

    // MARK: - Helpers

    /// A composition over `manager`. The composition holds the manager strongly, so the manager is
    /// checked for a leak when the test ends. The test of the gone manager builds its own, as it has
    /// to hold the only strong references in order to let them go.
    private func makeSUT<LM: DMLoadingManager>(
        _ manager: LM,
        file: StaticString = #filePath,
        line: UInt = #line
    ) -> HUDComposition {
        trackForMemoryLeaks(manager, file: file, line: line)
        return HUDComposition(manager)
    }

    private static var success: DMLoadableType {
        .success("Saved", provider: DefaultDMLoadingViewProvider().eraseToAnyViewProvider())
    }

    private static func settings(level: UIWindow.Level) -> DMLoadingManagerDefaultSettings {
        DMLoadingManagerDefaultSettings(autoHideDelay: .seconds(600), hudWindowLevel: level)
    }
}
