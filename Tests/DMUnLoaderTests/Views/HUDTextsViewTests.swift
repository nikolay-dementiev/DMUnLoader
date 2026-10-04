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

/// The error view and the progress view show a default text as the app's language gives it,
/// and a text the host wrote as the host wrote it. The texts are a stub that brackets every
/// text it is asked for, so a test sees whether a text was looked up.
@MainActor
final class HUDTextsViewTests: XCTestCase {

    func test_errorView_defaultTitle_showsTheLookedUpText() {
        XCTAssertNoThrow(try errorView(settings: DMErrorDefaultViewSettings()).inspect().find(text: "[An error has occurred!]"))
    }

    func test_errorView_defaultClose_showsTheLookedUpText() {
        XCTAssertNoThrow(try errorView(settings: DMErrorDefaultViewSettings()).inspect().find(button: "[Close]"))
    }

    func test_errorView_defaultRetry_showsTheLookedUpText() {
        XCTAssertNoThrow(try errorView(settings: DMErrorDefaultViewSettings()).inspect().find(button: "[Retry]"))
    }

    func test_progressView_defaultText_showsTheLookedUpText() {
        let sut = DefaultDMLoadingViewProvider().getLoadingView().environment(\.hudTexts, BracketedTexts())

        XCTAssertNoThrow(try sut.inspect().find(text: "[Loading...]"))
    }

    func test_errorView_hostClose_showsTheHostText() {
        let settings = DMErrorDefaultViewSettings(actionButtonCloseSettings: ActionButtonSettings(text: "Dismiss"))

        XCTAssertNoThrow(try errorView(settings: settings).inspect().find(button: "Dismiss"))
    }

    // MARK: - Helpers

    private func errorView(settings: DMErrorDefaultViewSettings) -> some View {
        DefaultDMLoadingViewProvider(errorViewSettings: settings)
            .getErrorView(
                error: DMAppError.custom("The server did not answer."),
                onRetry: DMButtonAction {},
                onClose: DMButtonAction {}
            )
            .environment(\.hudTexts, BracketedTexts())
    }
}

private struct BracketedTexts: HUDTexts {
    func text(for role: HUDDefaultText) -> String {
        "[\(role.english)]"
    }
}
