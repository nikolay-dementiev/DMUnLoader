//
//  DMUnLoader
//
//  Created by Mykola Dementiev
//

import Combine
import SwiftUI
import XCTest
import DMUnLoader

/// What `eraseToAnyViewProvider()` does today, pinned with a provider that changes after it
/// was erased: the erased provider keeps the settings of that moment, asks the original for
/// every view, and does not pass on the original's change notifications.
@MainActor
final class EraseToAnyViewProviderTests: XCTestCase {

    func test_settingsChangedAfterErasure_areNotSeenThroughTheErasedProvider() {
        let (sut, provider) = makeSUT()

        provider.loadingManagerSettings = StubDMLoadingManagerSettings(autoHideDelay: .seconds(9))
        provider.errorViewSettings = DMErrorDefaultViewSettings(
            actionButtonCloseSettings: ActionButtonSettings(text: "Dismiss")
        )

        XCTAssertEqual(
            sut.loadingManagerSettings.autoHideDelay,
            .seconds(1),
            "the manager settings are those of the moment of erasure"
        )
        XCTAssertEqual(
            sut.errorViewSettings.actionButtonCloseSettings.text,
            "Close",
            "the error view settings are those of the moment of erasure"
        )
    }

    func test_viewsAfterErasure_comeFromTheOriginalProviderEachTime() {
        let (sut, provider) = makeSUT()

        _ = sut.getLoadingView()
        _ = sut.getLoadingView()
        _ = sut.getErrorView(error: DMAppError.custom("failed"), onRetry: nil, onClose: DMButtonAction {})
        _ = sut.getSuccessView(object: "done")

        XCTAssertEqual(
            provider.viewRequests,
            ["loading", "loading", "error", "success"],
            "every view is asked of the original provider when it is needed"
        )
    }

    func test_erasedProvider_errorRequest_forwardsErrorRetryAndClose() throws {
        let (sut, provider) = makeSUT()
        let retry = DMButtonAction {}
        let close = DMButtonAction {}

        _ = sut.getErrorView(error: MarkerError(code: 42), onRetry: retry, onClose: close)

        XCTAssertEqual(provider.errorRequests.count, 1, "the original provider is asked for the error view once")
        let request = try XCTUnwrap(provider.errorRequests.first, "the original provider is asked for the error view")
        XCTAssertEqual(request.error as? MarkerError, MarkerError(code: 42), "the original gets the error that was asked about")
        XCTAssertEqual(request.retryID, retry.id, "the Retry action reaches the original as the Retry action")
        XCTAssertEqual(request.closeID, close.id, "the Close action reaches the original as the Close action")
    }

    func test_erasedProvider_errorRequestWithoutRetry_forwardsNoRetry() throws {
        let (sut, provider) = makeSUT()
        let close = DMButtonAction {}

        _ = sut.getErrorView(error: MarkerError(code: 7), onRetry: nil, onClose: close)

        let request = try XCTUnwrap(provider.errorRequests.first, "the original provider is asked for the error view")
        XCTAssertNil(request.retryID, "a missing Retry action stays missing: the original shows no Retry button")
        XCTAssertEqual(request.closeID, close.id, "the Close action reaches the original as the Close action")
    }

    func test_changeOfTheOriginalProvider_isNotPassedOn() {
        let (sut, provider) = makeSUT()
        let notifications = Counter()
        let subscription = sut.objectWillChange.sink { _ in notifications.count += 1 }

        provider.objectWillChange.send()

        XCTAssertEqual(notifications.count, 0, "the erased provider does not announce the original's changes")
        subscription.cancel()
    }

    func test_erasingAnErasedProvider_returnsIt() {
        let (sut, _) = makeSUT()

        XCTAssertTrue(sut.eraseToAnyViewProvider() === sut, "an erased provider is not wrapped again")
    }

    // MARK: - Helpers

    private final class Counter {
        var count = 0
    }

    private func makeSUT(
        file: StaticString = #filePath,
        line: UInt = #line
    ) -> (sut: AnyDMLoadingViewProvider, provider: MutableProvider) {
        let provider = MutableProvider()
        let sut = provider.eraseToAnyViewProvider()
        trackForMemoryLeaks(provider, file: file, line: line)
        trackForMemoryLeaks(sut, file: file, line: line)
        return (sut, provider)
    }
}

/// An error with an identity, so that a test can tell the one it passed from another.
private struct MarkerError: Error, Equatable {
    let code: Int
}

/// A provider whose settings change after it was erased, and which records the views it
/// is asked for.
@MainActor
private final class MutableProvider: @MainActor DMLoadingViewProvider {
    var loadingManagerSettings: any DMLoadingManagerSettings = StubDMLoadingManagerSettings(autoHideDelay: .seconds(1))
    var loadingViewSettings: any DMProgressViewSettings = DMProgressViewDefaultSettings()
    var errorViewSettings: any DMErrorViewSettings = DMErrorDefaultViewSettings()
    var successViewSettings: any DMSuccessViewSettings = DMSuccessDefaultViewSettings()
    private(set) var viewRequests: [String] = []
    private(set) var errorRequests: [ErrorRequest] = []

    /// What the original was asked for an error view: the error, and the identity of each action.
    struct ErrorRequest {
        let error: any Error
        let retryID: UUID?
        let closeID: UUID
    }

    func getLoadingView() -> some View {
        viewRequests.append("loading")
        return EmptyView()
    }

    func getErrorView(error: any Error, onRetry: (any DMAction)?, onClose: any DMAction) -> some View {
        viewRequests.append("error")
        errorRequests.append(ErrorRequest(error: error, retryID: onRetry?.id, closeID: onClose.id))
        return EmptyView()
    }

    func getSuccessView(object: any DMLoadableTypeSuccess) -> some View {
        viewRequests.append("success")
        return EmptyView()
    }

    nonisolated static func == (lhs: MutableProvider, rhs: MutableProvider) -> Bool {
        lhs === rhs
    }

    nonisolated func hash(into hasher: inout Hasher) {
        hasher.combine(ObjectIdentifier(self))
    }
}
