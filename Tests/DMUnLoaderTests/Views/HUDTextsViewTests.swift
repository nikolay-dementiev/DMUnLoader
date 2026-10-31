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

    func test_progressView_defaultText_labelsTheCardWithTheLookedUpText() throws {
        let sut = loadingView(text: nil, appearance: .standard)

        XCTAssertEqual(try cardLabel(of: sut), "[Loading...]", "the label of the card is the text that is shown")
    }

    func test_progressView_emptyText_labelsTheCardWithTheLookedUpDefaultText() throws {
        let sut = loadingView(text: "", appearance: .standard)

        XCTAssertEqual(try cardLabel(of: sut), "[Loading...]", "an empty text is labelled with the looked-up default text")
    }

    func test_progressView_emptyText_accessibleAppearance_labelsTheCardWithTheLookedUpDefaultText() throws {
        let sut = loadingView(text: "", appearance: .accessible)

        XCTAssertEqual(try cardLabel(of: sut), "[Loading...]", "the accessible card labels an empty text as well")
    }

    func test_progressView_hostText_labelsTheCardWithTheHostText() throws {
        let sut = loadingView(text: "Please wait", appearance: .standard)

        XCTAssertEqual(try cardLabel(of: sut), "Please wait", "the host's text is the label as the host wrote it")
    }

    func test_errorView_hostClose_showsTheHostText() {
        let settings = DMErrorDefaultViewSettings(actionButtonCloseSettings: ActionButtonSettings(text: "Dismiss"))

        XCTAssertNoThrow(try errorView(settings: settings).inspect().find(button: "Dismiss"))
    }

    // MARK: - Helpers

    /// The loading view of a provider whose loading text is `text` (the library's default when `nil`),
    /// in `appearance`, with the bracketing texts.
    private func loadingView(text: String?, appearance: DMHUDAppearance) -> some View {
        let settings = text.map { DMProgressViewDefaultSettings(loadingTextProperties: ProgressTextProperties(text: $0)) }
        return DefaultDMLoadingViewProvider(loadingViewSettings: settings)
            .getLoadingView()
            .environment(\.hudAppearance, appearance)
            .environment(\.hudTexts, BracketedTexts())
    }

    /// The accessibility label that the loading card carries, as one element.
    private func cardLabel(of view: some View) throws -> String {
        try view.inspect().find(ViewType.VStack.self).accessibilityLabel().string()
    }

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
