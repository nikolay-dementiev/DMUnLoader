//
//  DMUnLoader
//
//  Created by Mykola Dementiev
//

import DMAction
import SwiftUI
import XCTest
import DMUnLoader

/// A failure in a right-to-left language: the card mirrors, with Close on the right of Retry.
@MainActor
final class RightToLeftSnapshotTests: XCTestCase {

    func test_failureView_rightToLeft() {
        let failure = DefaultDMLoadingViewProvider().getErrorView(
            error: DMAppError.custom("The server did not answer."),
            onRetry: DMButtonAction {},
            onClose: DMButtonAction {}
        )

        assertImageSnapshot(
            of: LoadingViewContainer { failure }.environment(\.layoutDirection, .rightToLeft),
            style: .dark,
            named: "iPhone13Pro-dark"
        )
    }
}
