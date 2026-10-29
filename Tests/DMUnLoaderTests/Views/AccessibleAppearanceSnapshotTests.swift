//
//  DMUnLoader
//
//  Created by Mykola Dementiev
//

import DMAction
import SwiftUI
import XCTest
import DMUnLoader

/// The cards of the HUD in the accessible look, with the card the library draws, in light and in dark
/// mode, at the default text size and at accessibility sizes. The cards of the released look are
/// recorded in the other snapshot tests and are not touched.
@MainActor
final class AccessibleAppearanceSnapshotTests: XCTestCase {

    func test_accessibleAppearance_loadingView_defaultSize() {
        let loading = DefaultDMLoadingViewProvider(appearance: .accessible).getLoadingView()

        assertLightAndDark(of: AccessibleHUDContainer { loading })
    }

    func test_accessibleAppearance_loadingView_accessibility5_longText() {
        let loading = DefaultDMLoadingViewProvider(appearance: .accessible).getLoadingView()
        let texts = FixedHUDTexts(loading: "Loading the data, please wait a moment while everything is made ready for you")

        assertLightAndDark(
            of: AccessibleHUDContainer { loading }
                .environment(\.hudTexts, texts)
                .dynamicTypeSize(.accessibility5)
        )
    }

    func test_accessibleAppearance_failureView_withRetry_defaultSize() {
        let failure = DefaultDMLoadingViewProvider(appearance: .accessible).getErrorView(
            error: DMAppError.custom("The server did not answer."),
            onRetry: DMButtonAction {},
            onClose: DMButtonAction {}
        )

        assertLightAndDark(of: AccessibleHUDContainer { failure })
    }

    func test_accessibleAppearance_failureView_withRetry_accessibility3() {
        let failure = DefaultDMLoadingViewProvider(appearance: .accessible).getErrorView(
            error: DMAppError.custom("The server did not answer."),
            onRetry: DMButtonAction {},
            onClose: DMButtonAction {}
        )

        assertLightAndDark(of: AccessibleHUDContainer { failure }.dynamicTypeSize(.accessibility3))
    }

    func test_accessibleAppearance_successView_defaultSize() {
        let success = DefaultDMLoadingViewProvider(appearance: .accessible).getSuccessView(object: "Saved")

        assertLightAndDark(of: AccessibleHUDContainer { success })
    }

    // MARK: - Helpers

    private func assertLightAndDark(
        of view: some View,
        file: StaticString = #filePath,
        testName: String = #function,
        line: UInt = #line
    ) {
        assertImageSnapshot(of: view, style: .light, named: "iPhone13Pro-light", file: file, testName: testName, line: line)
        assertImageSnapshot(of: view, style: .dark, named: "iPhone13Pro-dark", file: file, testName: testName, line: line)
    }
}

/// The HUD as it is drawn over a screen: the dim of the default backdrop and the card of the
/// accessible look around the view of a state.
private struct AccessibleHUDContainer<Content: View>: View {
    @ViewBuilder var content: Content

    var body: some View {
        ZStack {
            Color.black.opacity(0.2)
                .ignoresSafeArea()

            HUDCard(appearance: .accessible, isShown: true, content: AnyView(content))
                .padding(15)
        }
        .environment(\.hudAppearance, .accessible)
    }
}
