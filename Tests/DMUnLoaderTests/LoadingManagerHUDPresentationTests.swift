//
//  DMUnLoader
//
//  Created by Mykola Dementiev
//

import UIKit
import XCTest
import DMUnLoader

/// The presentation that the layer of the loading manager makes: the identity of one manager, and the
/// composition that reads that manager. No scene and no presenter is needed to see either.
@MainActor
final class LoadingManagerHUDPresentationTests: XCTestCase {

    func test_presentations_ofTwoManagers_haveTheIdentityOfEachOfThem() {
        let (first, firstPresentation) = makeSUT()
        let (second, secondPresentation) = makeSUT()

        XCTAssertEqual(
            firstPresentation.id,
            ObjectIdentifier(first),
            "the first presentation has the identity of the first manager"
        )
        XCTAssertEqual(
            secondPresentation.id,
            ObjectIdentifier(second),
            "the second presentation has the identity of the second manager"
        )
        XCTAssertNotEqual(firstPresentation.id, secondPresentation.id, "two managers are two identities")
    }

    func test_presentations_ofTwoManagers_haveAContentThatReadsItsOwnManager() {
        let (_, quiet) = makeSUT(state: .none, level: .normal)
        let (_, showing) = makeSUT(state: Self.success, level: .alert)

        XCTAssertFalse(quiet.content.showsHUD, "the first content reads the first manager, which shows nothing")
        XCTAssertEqual(quiet.content.windowLevel, .normal, "the first content reads the settings of the first manager")
        XCTAssertTrue(showing.content.showsHUD, "the second content reads the second manager, which shows a success")
        XCTAssertEqual(showing.content.windowLevel, .alert, "the second content reads the settings of the second manager")
    }

    // MARK: - Helpers

    /// The presentation of a manager. The presentation holds the manager strongly, so the manager is
    /// checked for a leak when the test ends.
    private func makeSUT(
        state: DMLoadableType = .none,
        level: UIWindow.Level = .normal,
        file: StaticString = #filePath,
        line: UInt = #line
    ) -> (manager: HostLoadingManagerSpy, presentation: HUDPresentation<HUDComposition>) {
        let manager = HostLoadingManagerSpy(
            loadableState: state,
            settings: DMLoadingManagerDefaultSettings(autoHideDelay: .seconds(600), hudWindowLevel: level)
        )
        trackForMemoryLeaks(manager, file: file, line: line)
        return (manager, HUDPresentation(manager))
    }

    private static var success: DMLoadableType {
        .success("Saved", provider: DefaultDMLoadingViewProvider().eraseToAnyViewProvider())
    }
}
