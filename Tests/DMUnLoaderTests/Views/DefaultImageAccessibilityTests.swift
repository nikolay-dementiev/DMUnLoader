//
//  DMUnLoader
//
//  Created by Mykola Dementiev
//

import DMAction
import SwiftUI
import ViewInspector
import XCTest
import DMUnLoader

/// The default images of the failure and the success view only decorate: the texts beside them
/// name the state. An image that the host supplies keeps whatever the host gave it.
@MainActor
final class DefaultImageAccessibilityTests: XCTestCase {

    func test_failureView_defaultImage_isHiddenFromAccessibility() throws {
        let failure = failureView(with: DefaultDMLoadingViewProvider())

        XCTAssertTrue(
            try failure.inspect().find(ViewType.Image.self).accessibilityHidden(),
            "assistive technology does not read the default warning sign"
        )
    }

    func test_failureView_hostImage_keepsItsAccessibility() throws {
        let provider = DefaultDMLoadingViewProvider(
            errorViewSettings: DMErrorDefaultViewSettings(
                errorImageSettings: ErrorImageSettings(image: Image(systemName: "wifi.exclamationmark"))
            )
        )

        let image = try failureView(with: provider).inspect().find(ViewType.Image.self)

        XCTAssertThrowsError(try image.accessibilityHidden(), "the host's image is left as the host made it")
    }

    func test_successView_defaultImage_isHiddenFromAccessibility() throws {
        let success = DefaultDMLoadingViewProvider().getSuccessView(object: "Saved")

        XCTAssertTrue(
            try success.inspect().find(ViewType.Image.self).accessibilityHidden(),
            "assistive technology does not read the default checkmark"
        )
    }

    func test_successView_hostImage_keepsItsAccessibility() throws {
        let provider = DefaultDMLoadingViewProvider(
            successViewSettings: DMSuccessDefaultViewSettings(
                successImageProperties: SuccessImageProperties(image: Image(systemName: "star.fill"))
            )
        )

        let image = try provider.getSuccessView(object: "Saved").inspect().find(ViewType.Image.self)

        XCTAssertThrowsError(try image.accessibilityHidden(), "the host's image is left as the host made it")
    }

    // MARK: - Helpers

    private func failureView(with provider: DefaultDMLoadingViewProvider) -> some View {
        provider.getErrorView(
            error: DMAppError.custom("The server did not answer."),
            onRetry: DMButtonAction {},
            onClose: DMButtonAction {}
        )
    }
}
