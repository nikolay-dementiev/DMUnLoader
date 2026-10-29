//
//  DMUnLoader
//
//  Created by Mykola Dementiev
//

import DMVariableBlurView
import XCTest
import DMUnLoader

/// The failure of the backdrop as a value: how a reason of DMVariableBlurView becomes the failure the
/// host sees, and what the handler that the HUD gives the blur view does with it.
@MainActor
final class HUDBackdropFailureTests: XCTestCase {

    // MARK: - The mapping

    func test_backdropFailure_eachReasonOfTheLeaf_mapsToAFailureOfTheLibrary() {
        XCTAssertEqual(
            DMHUDBackdropFailure(DMVariableBlurError.effectUnavailable),
            .effectUnavailable,
            "the system does not offer the effect"
        )
        XCTAssertEqual(
            DMHUDBackdropFailure(DMVariableBlurError.maskCreationFailed),
            .maskCreationFailed,
            "the mask could not be created"
        )
        XCTAssertEqual(
            DMHUDBackdropFailure(DMVariableBlurError.invalidMaxBlurRadius(-1)),
            .invalidConfiguration,
            "an invalid radius is an invalid configuration"
        )
        XCTAssertEqual(
            DMHUDBackdropFailure(DMVariableBlurError.invalidCenterBandProportion(2)),
            .invalidConfiguration,
            "an invalid band is an invalid configuration"
        )
        XCTAssertEqual(
            DMHUDBackdropFailure(DMVariableBlurError.invalidStartOffset(.infinity)),
            .invalidConfiguration,
            "an invalid offset is an invalid configuration"
        )
    }

    // MARK: - The handler of the blur view

    func test_backdropFailure_effectUnavailable_reportsToTheHostOnce() throws {
        let spy = BackdropFailureSpy()

        let sut = makeSUT(host: { spy.record($0) })

        let leafHandler = try XCTUnwrap(sut, "a host that has a handler gives the blur view one")
        leafHandler(.effectUnavailable)
        XCTAssertEqual(spy.received, [.effectUnavailable], "the host receives the failure once, as the type of the library")
    }

    func test_backdropFailure_forwarderOfAHostWithoutHandler_givesTheBlurViewNoHandler() {
        XCTAssertNil(
            makeSUT(host: nil),
            "no handler of the host, no handler of the blur view: it keeps writing its line to the log"
        )
    }

    // MARK: - Helpers

    /// The handler that the HUD gives the blur view for a host with `host` for its handler.
    private func makeSUT(
        host: (@MainActor @Sendable (DMHUDBackdropFailure) -> Void)?
    ) -> (@MainActor (DMVariableBlurError) -> Void)? {
        HUDBackdropFailureForwarder.leafHandler(for: host)
    }
}
