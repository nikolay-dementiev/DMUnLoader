//
//  DMUnLoader
//
//  Created by Mykola Dementiev
//

import DMAction
import SwiftUI
import XCTest
import DMUnLoader

/// The cards of the HUD at a large accessibility text size, and its button style in light and
/// dark, as they are. At this size the progress card keeps to half of its frame geometry and
/// clips its text, which 1.1.0 records and does not change.
@MainActor
final class AccessibilitySnapshotTests: XCTestCase {

    func test_loadingView_accessibility3() {
        let loading = DefaultDMLoadingViewProvider().getLoadingView()

        assertImageSnapshot(
            of: LoadingViewContainer { loading }.dynamicTypeSize(.accessibility3),
            style: .dark,
            named: "iPhone13Pro-dark"
        )
    }

    func test_successView_accessibility3() {
        let success = DefaultDMLoadingViewProvider().getSuccessView(object: "Saved")

        assertImageSnapshot(
            of: LoadingViewContainer { success }.dynamicTypeSize(.accessibility3),
            style: .dark,
            named: "iPhone13Pro-dark"
        )
    }

    func test_failureView_accessibility3() {
        let failure = DefaultDMLoadingViewProvider().getErrorView(
            error: DMAppError.custom("The server did not answer."),
            onRetry: DMButtonAction {},
            onClose: DMButtonAction {}
        )

        assertImageSnapshot(
            of: LoadingViewContainer { failure }.dynamicTypeSize(.accessibility3),
            style: .dark,
            named: "iPhone13Pro-dark"
        )
    }

    func test_hudButtonStyle_lightAndDark() {
        let button = LoadingViewContainer {
            Button("Retry") {}
                .buttonStyle(ActionButtonSettings(text: "Retry").styleFactory())
        }

        assertImageSnapshot(of: button, style: .light, named: "iPhone13Pro-light")
        assertImageSnapshot(of: button, style: .dark, named: "iPhone13Pro-dark")
    }
}
