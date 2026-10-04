//
//  DMUnLoader
//
//  Created by Mykola Dementiev
//

import DMAction
import XCTest
import DMUnLoader

/// Two states are equal when they are the same case and show the same thing: the provider
/// given to the manager, a payload or an error of the same type and description, and the
/// same retry action.
@MainActor
final class LoadableStateEqualityTests: XCTestCase {

    // MARK: - What a state shows

    func test_loadableState_differentProviders_areNotEqual() {
        let first = DefaultDMLoadingViewProvider().eraseToAnyViewProvider()
        let second = DefaultDMLoadingViewProvider().eraseToAnyViewProvider()

        XCTAssertNotEqual(
            DMLoadableType.loading(provider: first),
            DMLoadableType.loading(provider: second),
            "two loading states with a provider each"
        )
        XCTAssertNotEqual(
            DMLoadableType.success("Done", provider: first),
            DMLoadableType.success("Done", provider: second),
            "two successes with a provider each"
        )
        XCTAssertNotEqual(
            DMLoadableType.failure(error: FirstError.timeout, provider: first),
            DMLoadableType.failure(error: FirstError.timeout, provider: second),
            "two failures with a provider each"
        )
    }

    func test_loadableState_failuresWithDifferentRetryActions_areNotEqual() {
        let provider = DefaultDMLoadingViewProvider().eraseToAnyViewProvider()

        XCTAssertNotEqual(
            DMLoadableType.failure(error: FirstError.timeout, provider: provider, onRetry: DMButtonAction {}),
            DMLoadableType.failure(error: FirstError.timeout, provider: provider, onRetry: DMButtonAction {})
        )
    }

    func test_loadableState_failureWithRetryAndFailureWithout_areNotEqual() {
        let provider = DefaultDMLoadingViewProvider().eraseToAnyViewProvider()

        XCTAssertNotEqual(
            DMLoadableType.failure(error: FirstError.timeout, provider: provider, onRetry: DMButtonAction {}),
            DMLoadableType.failure(error: FirstError.timeout, provider: provider)
        )
    }

    func test_loadableState_errorsOfDifferentTypesWithTheSameDescription_areNotEqual() {
        let provider = DefaultDMLoadingViewProvider().eraseToAnyViewProvider()

        XCTAssertNotEqual(
            DMLoadableType.failure(error: FirstError.timeout, provider: provider),
            DMLoadableType.failure(error: SecondError.timeout, provider: provider)
        )
    }

    func test_loadableState_payloadsOfDifferentTypesWithTheSameDescription_areNotEqual() {
        let provider = DefaultDMLoadingViewProvider().eraseToAnyViewProvider()

        XCTAssertNotEqual(
            DMLoadableType.success("Done", provider: provider),
            DMLoadableType.success(Payload(description: "Done"), provider: provider)
        )
    }

    // MARK: - Equal states

    func test_loadableState_sameProviderErasedTwice_areEqual() {
        let provider = DefaultDMLoadingViewProvider()
        let first = provider.eraseToAnyViewProvider()
        let second = provider.eraseToAnyViewProvider()

        XCTAssertEqual(DMLoadableType.loading(provider: first), DMLoadableType.loading(provider: second))
    }

    func test_loadableState_failuresWithTheSameRetryAction_areEqual() {
        let provider = DefaultDMLoadingViewProvider().eraseToAnyViewProvider()
        let retry = DMButtonAction {}

        XCTAssertEqual(
            DMLoadableType.failure(error: FirstError.timeout, provider: provider, onRetry: retry),
            DMLoadableType.failure(error: FirstError.timeout, provider: provider, onRetry: retry)
        )
    }

    // MARK: - Hashing

    func test_loadableState_equalStates_haveEqualHashValues() {
        let provider = DefaultDMLoadingViewProvider()
        // Both erasures stay alive, so the second cannot take the address of the first.
        let first = provider.eraseToAnyViewProvider()
        let second = provider.eraseToAnyViewProvider()
        let retry = DMButtonAction {}

        XCTAssertNotEqual(
            DMLoadableType.none.hashValue,
            DMLoadableType.loading(provider: first).hashValue,
            "a state of no load hashes apart from a loading one"
        )
        XCTAssertEqual(
            DMLoadableType.loading(provider: first).hashValue,
            DMLoadableType.loading(provider: second).hashValue,
            "loading with one provider erased twice hashes alike"
        )
        XCTAssertEqual(
            DMLoadableType.success("Done", provider: first).hashValue,
            DMLoadableType.success("Done", provider: second).hashValue,
            "equal successes hash alike"
        )
        XCTAssertEqual(
            DMLoadableType.failure(error: FirstError.timeout, provider: first, onRetry: retry).hashValue,
            DMLoadableType.failure(error: FirstError.timeout, provider: second, onRetry: retry).hashValue,
            "equal failures hash alike"
        )
    }
}

private enum FirstError: Error {
    case timeout
}

private enum SecondError: Error {
    case timeout
}

private struct Payload: DMLoadableTypeSuccess {
    let description: String
}
