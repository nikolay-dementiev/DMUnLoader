//
//  DMUnLoader
//
//  Created by Mykola Dementiev
//

import SwiftUI
import ViewInspector
import XCTest
import DMUnLoader

/// The look of the HUD: chosen by a provider, kept by the type erasure, held by a state, and handed
/// by the HUD to the views of its card.
@MainActor
final class HUDAppearanceTests: XCTestCase {

    // MARK: - The two looks

    func test_standardAndAccessible_areDifferentValues() {
        XCTAssertNotEqual(DMHUDAppearance.standard, DMHUDAppearance.accessible, "the opt-in is not the released look")
    }

    // MARK: - Providers

    func test_conformerWrittenForVersion110_compilesUnchangedAndKeepsTheReleasedLook() {
        let sut = ConformerOfVersion110()

        XCTAssertEqual(sut.hudAppearance, .standard, "a provider that never heard of the requirement is standard")
    }

    func test_defaultProvider_existingInitializer_isStandard() {
        XCTAssertEqual(DefaultDMLoadingViewProvider().hudAppearance, .standard, "no argument, no change of look")
    }

    func test_defaultProvider_initWithAppearance_carriesIt() {
        XCTAssertEqual(
            DefaultDMLoadingViewProvider(appearance: .accessible).hudAppearance,
            .accessible,
            "the provider reports the look it was given"
        )
        XCTAssertEqual(
            DefaultDMLoadingViewProvider(appearance: .standard).hudAppearance,
            .standard,
            "the standard look is a look that can be given too"
        )
    }

    func test_defaultProvider_initWithStandard_hasTheDefaultViewSettings() {
        let sut = DefaultDMLoadingViewProvider(appearance: .standard)

        XCTAssertEqual(
            sut.loadingViewSettings.loadingTextProperties,
            DMProgressViewDefaultSettings().loadingTextProperties,
            "the loading text is that of the released look"
        )
        XCTAssertEqual(
            sut.loadingViewSettings.progressIndicatorProperties,
            DMProgressViewDefaultSettings().progressIndicatorProperties,
            "the indicator is that of the released look"
        )
        XCTAssertEqual(
            sut.errorViewSettings.errorTextSettings,
            DMErrorDefaultViewSettings().errorTextSettings,
            "the error text is that of the released look"
        )
        XCTAssertEqual(
            sut.errorViewSettings.errorImageSettings,
            DMErrorDefaultViewSettings().errorImageSettings,
            "the error image is that of the released look"
        )
        XCTAssertEqual(
            sut.successViewSettings.successTextProperties,
            DMSuccessDefaultViewSettings().successTextProperties,
            "the success text is that of the released look"
        )
        // The identifier of the image properties differs from one value to the next, so the fields
        // that draw are compared.
        let image = sut.successViewSettings.successImageProperties
        let releasedImage = DMSuccessDefaultViewSettings().successImageProperties
        XCTAssertEqual(image.image, releasedImage.image, "the success image is the checkmark of the released look")
        XCTAssertEqual(image.frame, releasedImage.frame, "the success image has the size of the released look")
        XCTAssertEqual(
            image.foregroundColor,
            releasedImage.foregroundColor,
            "the success image has the colour of the released look"
        )
    }

    func test_defaultProvider_initWithAccessible_hasTheViewSettingsOfTheAccessibleLook() {
        let sut = DefaultDMLoadingViewProvider(appearance: .accessible)
        let accessible = DMHUDAppearance.accessible

        XCTAssertEqual(
            sut.loadingViewSettings.loadingTextProperties,
            accessible.loadingViewSettings.loadingTextProperties,
            "the loading text is that of the accessible look"
        )
        XCTAssertEqual(
            sut.loadingViewSettings.progressIndicatorProperties,
            accessible.loadingViewSettings.progressIndicatorProperties,
            "the indicator is that of the accessible look"
        )
        XCTAssertEqual(
            sut.errorViewSettings.errorTextSettings,
            accessible.errorViewSettings.errorTextSettings,
            "the error text is that of the accessible look"
        )
        XCTAssertEqual(
            sut.errorViewSettings.errorImageSettings,
            accessible.errorViewSettings.errorImageSettings,
            "the error image is that of the accessible look"
        )
        XCTAssertEqual(
            sut.errorViewSettings.actionButtonCloseSettings.text,
            accessible.errorViewSettings.actionButtonCloseSettings.text,
            "the Close button has the text of the accessible look"
        )
        XCTAssertEqual(
            sut.errorViewSettings.actionButtonRetrySettings.text,
            accessible.errorViewSettings.actionButtonRetrySettings.text,
            "the Retry button has the text of the accessible look"
        )
        XCTAssertEqual(
            sut.successViewSettings.successTextProperties,
            accessible.successViewSettings.successTextProperties,
            "the success text is that of the accessible look"
        )
        // The identifier of the image properties differs from one value to the next, so the fields
        // that draw are compared.
        let image = sut.successViewSettings.successImageProperties
        let accessibleImage = accessible.successViewSettings.successImageProperties
        XCTAssertEqual(image.image, accessibleImage.image, "the success image is the mark of the accessible look")
        XCTAssertEqual(image.frame, accessibleImage.frame, "the success image has the size of the accessible look")
        XCTAssertEqual(
            image.foregroundColor,
            accessibleImage.foregroundColor,
            "the success image has the colour of the accessible look"
        )
    }

    func test_providerThatOnlyOptsIn_givesTheLibraryViewsTheSettingsOfTheAccessibleLook() {
        let sut = ProviderThatOnlyOptsIn()
        let accessible = DMHUDAppearance.accessible

        XCTAssertEqual(
            sut.loadingViewSettings.loadingTextProperties,
            accessible.loadingViewSettings.loadingTextProperties,
            "the loading text is that of the accessible look, not the white of the released one"
        )
        XCTAssertEqual(
            sut.loadingViewSettings.progressIndicatorProperties,
            accessible.loadingViewSettings.progressIndicatorProperties,
            "the indicator is that of the accessible look"
        )
        XCTAssertEqual(
            sut.errorViewSettings.errorTextSettings,
            accessible.errorViewSettings.errorTextSettings,
            "the error text is that of the accessible look"
        )
        XCTAssertEqual(
            sut.errorViewSettings.errorImageSettings,
            accessible.errorViewSettings.errorImageSettings,
            "the error image is that of the accessible look"
        )
        XCTAssertEqual(
            sut.successViewSettings.successTextProperties,
            accessible.successViewSettings.successTextProperties,
            "the success text is that of the accessible look"
        )
        XCTAssertEqual(
            sut.successViewSettings.successImageProperties.foregroundColor,
            accessible.successViewSettings.successImageProperties.foregroundColor,
            "the success image has the colour of the accessible look"
        )
    }

    func test_providerThatImplementsNothing_keepsTheDefaultViewSettings() {
        let sut = ProviderThatImplementsNothing()

        XCTAssertEqual(sut.hudAppearance, .standard, "a provider that implements nothing is standard")
        XCTAssertEqual(
            sut.loadingViewSettings.loadingTextProperties,
            DMProgressViewDefaultSettings().loadingTextProperties,
            "the loading text is that of the released look"
        )
        XCTAssertEqual(
            sut.errorViewSettings.errorTextSettings,
            DMErrorDefaultViewSettings().errorTextSettings,
            "the error text is that of the released look"
        )
        XCTAssertEqual(
            sut.successViewSettings.successTextProperties,
            DMSuccessDefaultViewSettings().successTextProperties,
            "the success text is that of the released look"
        )
    }

    // MARK: - Type erasure

    func test_erasedProvider_forwardsTheAppearanceOfTheDefaultProvider() {
        let accessible = DefaultDMLoadingViewProvider(appearance: .accessible).eraseToAnyViewProvider()
        let standard = DefaultDMLoadingViewProvider(appearance: .standard).eraseToAnyViewProvider()

        XCTAssertEqual(accessible.hudAppearance, .accessible, "erasing keeps the opt-in")
        XCTAssertEqual(standard.hudAppearance, .standard, "erasing keeps the released look")
    }

    func test_erasedProvider_forwardsTheAppearanceOfAProviderOfTheHost() {
        let accessible = OptedInProvider(appearance: .accessible).eraseToAnyViewProvider()

        XCTAssertEqual(accessible.hudAppearance, .accessible, "a provider that opts in through the requirement stays opted in")
    }

    func test_erasedProvider_erasedAgain_keepsTheAppearance() {
        let once = DefaultDMLoadingViewProvider(appearance: .accessible).eraseToAnyViewProvider()

        XCTAssertEqual(once.eraseToAnyViewProvider().hudAppearance, .accessible, "erasing an erased provider keeps the opt-in")
    }

    // MARK: - State

    func test_state_takesTheAppearanceOfItsProvider() {
        let accessible = DefaultDMLoadingViewProvider(appearance: .accessible).eraseToAnyViewProvider()
        let standard = DefaultDMLoadingViewProvider().eraseToAnyViewProvider()
        let error = DMAppError.custom("failed")

        let states: [StateCase] = [
            StateCase(name: "loading, accessible", state: .loading(provider: accessible), expected: .accessible),
            StateCase(name: "loading, standard", state: .loading(provider: standard), expected: .standard),
            StateCase(name: "failure, accessible", state: .failure(error: error, provider: accessible), expected: .accessible),
            StateCase(name: "failure, standard", state: .failure(error: error, provider: standard), expected: .standard),
            StateCase(name: "success, accessible", state: .success("saved", provider: accessible), expected: .accessible),
            StateCase(name: "success, standard", state: .success("saved", provider: standard), expected: .standard),
            StateCase(name: "none", state: .none, expected: .standard)
        ]
        for item in states {
            XCTAssertEqual(
                item.state.hudAppearance,
                item.expected,
                "\(item.name): the look of a state is that of its provider"
            )
        }
    }

    // MARK: - The HUD hands it on

    func test_hud_handsTheAppearanceOfTheProviderToTheViewsOfItsCard() {
        let accessible = handedAppearance(of: OptedInProvider(appearance: .accessible))
        let standard = handedAppearance(of: OptedInProvider(appearance: .standard))

        XCTAssertEqual(accessible, .accessible, "a view of the card reads the look of the provider it was made by")
        XCTAssertEqual(standard, .standard, "a view of the standard look reads the standard look")
    }

    // MARK: - Helpers

    /// The look that the loading view of `provider` reads from its environment once the HUD shows it.
    private func handedAppearance(of provider: OptedInProvider) -> DMHUDAppearance? {
        let manager = DMLoadingManagerMain(
            state: .loading(provider: provider.eraseToAnyViewProvider()),
            settings: DMLoadingManagerDefaultSettings(autoHideDelay: .seconds(600))
        )
        trackForMemoryLeaks(manager)
        ViewHosting.host(view: DMHudSceneView(loadingManager: manager))
        defer { ViewHosting.expel() }

        let deadline = Date().addingTimeInterval(TestTiming.callbackAllowance)
        while provider.recorder.seen.isEmpty, Date() < deadline {
            RunLoop.current.run(until: Date().addingTimeInterval(0.02))
        }
        return provider.recorder.seen.last
    }
}

/// A state with the look that the HUD must take for it.
private struct StateCase {
    let name: String
    let state: DMLoadableType
    let expected: DMHUDAppearance
}

/// What the loading view of a provider found in its environment.
@MainActor
private final class AppearanceRecorder {
    var seen: [DMHUDAppearance] = []
}

private struct AppearanceProbe: View {
    @Environment(\.hudAppearance) private var appearance
    let recorder: AppearanceRecorder

    var body: some View {
        Color.clear
            .frame(width: 10, height: 10)
            .onAppear { recorder.seen.append(appearance) }
    }
}

/// A provider written the way one was against 1.1.0, which has the four settings and the three views and
/// nothing else. It does not implement `hudAppearance`, and it compiles with the requirement all the same.
@MainActor
private final class ConformerOfVersion110: @MainActor DMLoadingViewProvider {
    let loadingManagerSettings: any DMLoadingManagerSettings = DMLoadingManagerDefaultSettings()
    let loadingViewSettings: any DMProgressViewSettings = DMProgressViewDefaultSettings()
    let errorViewSettings: any DMErrorViewSettings = DMErrorDefaultViewSettings()
    let successViewSettings: any DMSuccessViewSettings = DMSuccessDefaultViewSettings()

    func getLoadingView() -> Text {
        Text("A loading of the host")
    }

    func getErrorView(error: any Error, onRetry: (any DMAction)?, onClose: any DMAction) -> Text {
        Text("An error of the host")
    }

    func getSuccessView(object: any DMLoadableTypeSuccess) -> Text {
        Text("A success of the host")
    }
}

/// A provider that opts in and keeps the library's views: it implements the requirement and nothing
/// else, as the documentation of the protocol invites.
@MainActor
private final class ProviderThatOnlyOptsIn: @MainActor DMLoadingViewProvider {
    var hudAppearance: DMHUDAppearance { .accessible }
}

/// A provider that implements nothing: every requirement has its default.
@MainActor
private final class ProviderThatImplementsNothing: @MainActor DMLoadingViewProvider {}

/// A provider of a host that opts in: it implements the requirement, and its loading view reports what
/// it finds in its environment.
@MainActor
private final class OptedInProvider: @MainActor DMLoadingViewProvider {
    let hudAppearance: DMHUDAppearance
    let recorder = AppearanceRecorder()

    init(appearance: DMHUDAppearance) {
        self.hudAppearance = appearance
    }

    func getLoadingView() -> AppearanceProbe {
        AppearanceProbe(recorder: recorder)
    }

    func getErrorView(error: any Error, onRetry: (any DMAction)?, onClose: any DMAction) -> Text {
        Text("An error of the host")
    }

    func getSuccessView(object: any DMLoadableTypeSuccess) -> Text {
        Text("A success of the host")
    }
}
