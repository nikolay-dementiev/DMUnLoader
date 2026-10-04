//
//  DMUnLoader
//
//  Created by Mykola Dementiev
//

import XCTest
import DMUnLoader

/// How a success, a failure without Retry and a failure with Retry leave the screen, as the
/// plain policies of the inner core apply the rules of the settings.
final class HUDDismissalRulesTests: XCTestCase {

    private let autoHideDelay: Duration = .seconds(2)

    // MARK: - Defaults

    func test_defaultRules_everyKindHidesAfterTheDelayAndOnAnyTap() {
        let rules = DMHUDDismissalRules()
        let before1_1 = DMHUDDismissal(autoHide: .afterAutoHideDelay, cardTapHides: true, backdropTapHides: true)

        XCTAssertEqual(rules.success, before1_1, "a success leaves as before 1.1.0")
        XCTAssertEqual(rules.failureWithoutRetry, before1_1, "a failure without Retry leaves as before 1.1.0")
        XCTAssertEqual(rules.failureWithRetry, before1_1, "a failure with Retry leaves as before 1.1.0")
    }

    func test_settings_withOnlyTheDelay_getTheDefaultRules() {
        XCTAssertEqual(
            DelayOnlySettings().hudDismissal,
            DMHUDDismissalRules(),
            "a settings type that sets only the delay gets the rules of 1.0"
        )
    }

    // MARK: - Auto-hide

    func test_delay_defaultRules_everyKindWaitsAutoHideDelay() {
        for phase in [HUDPhase.success, .failure, .failureWithRetry] {
            XCTAssertEqual(
                AutoHidePolicy.delay(for: phase, rules: DMHUDDismissalRules(), autoHideDelay: autoHideDelay),
                autoHideDelay,
                "\(phase) hides after the delay of the settings by default"
            )
        }
    }

    func test_delay_noneAndLoading_isNil() {
        for phase in [HUDPhase.none, .loading] {
            XCTAssertNil(
                AutoHidePolicy.delay(for: phase, rules: DMHUDDismissalRules(), autoHideDelay: autoHideDelay),
                "\(phase) does not hide by itself"
            )
        }
    }

    func test_delay_afterRule_usesItsOwnDelay() {
        let rules = DMHUDDismissalRules(success: DMHUDDismissal(autoHide: .after(.seconds(5))))

        XCTAssertEqual(
            AutoHidePolicy.delay(for: .success, rules: rules, autoHideDelay: autoHideDelay),
            .seconds(5),
            "a success with a delay of its own waits that delay, not the one of the settings"
        )
    }

    func test_delay_neverRule_isNil() {
        let rules = DMHUDDismissalRules(failureWithRetry: DMHUDDismissal(autoHide: .never))

        XCTAssertNil(
            AutoHidePolicy.delay(for: .failureWithRetry, rules: rules, autoHideDelay: .seconds(2)),
            "a failure with Retry that never hides by itself schedules nothing"
        )
    }

    // MARK: - Taps

    func test_tapDismisses_cardOffBackdropOn_onlyTheBackdropHides() {
        let rules = DMHUDDismissalRules(failureWithRetry: DMHUDDismissal(cardTapHides: false))

        XCTAssertFalse(
            DismissPolicy.tapDismisses(.failureWithRetry, on: .card, rules: rules),
            "a tap on the card keeps the failure"
        )
        XCTAssertTrue(
            DismissPolicy.tapDismisses(.failureWithRetry, on: .backdrop, rules: rules),
            "a tap outside the card hides it"
        )
    }

    func test_tapDismisses_eachKind_followsItsOwnRule() {
        let rules = DMHUDDismissalRules(
            success: DMHUDDismissal(backdropTapHides: false),
            failureWithoutRetry: DMHUDDismissal(cardTapHides: false),
            failureWithRetry: DMHUDDismissal(cardTapHides: false, backdropTapHides: false)
        )

        XCTAssertTrue(DismissPolicy.tapDismisses(.success, on: .card, rules: rules), "a success follows its card rule")
        XCTAssertFalse(DismissPolicy.tapDismisses(.success, on: .backdrop, rules: rules), "a success follows its backdrop rule")
        XCTAssertFalse(
            DismissPolicy.tapDismisses(.failure, on: .card, rules: rules),
            "a failure without Retry follows its card rule"
        )
        XCTAssertTrue(
            DismissPolicy.tapDismisses(.failure, on: .backdrop, rules: rules),
            "a failure without Retry follows its backdrop rule"
        )
        XCTAssertFalse(
            DismissPolicy.tapDismisses(.failureWithRetry, on: .backdrop, rules: rules),
            "a failure with Retry follows its own rule"
        )
    }

    func test_tapDismisses_loading_neverForEitherTarget() {
        let rules = DMHUDDismissalRules()

        XCTAssertFalse(DismissPolicy.tapDismisses(.loading, on: .card, rules: rules), "a tap on the card keeps the loading HUD")
        XCTAssertFalse(DismissPolicy.tapDismisses(.loading, on: .backdrop, rules: rules), "a tap outside keeps the loading HUD")
    }

    // MARK: - Phase

    @MainActor
    func test_phase_ofAFailureWithRetry_isFailureWithRetry() {
        let failure = DMLoadableType.failure(
            error: DMAppError.custom("failed"),
            provider: DefaultDMLoadingViewProvider().eraseToAnyViewProvider(),
            onRetry: DMButtonAction {}
        )

        XCTAssertEqual(failure.phase, .failureWithRetry, "a failure with a retry action has a phase of its own")
    }

    func test_showsHUD_failureWithRetry_isTrue() {
        XCTAssertTrue(HUDPhase.failureWithRetry.showsHUD, "a failure with Retry shows a HUD")
    }
}

private struct DelayOnlySettings: DMLoadingManagerSettings {
    let autoHideDelay: Duration = .seconds(2)
}
