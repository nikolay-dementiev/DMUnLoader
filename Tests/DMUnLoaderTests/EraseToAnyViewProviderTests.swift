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

/// A provider whose settings change after it was erased, and which records the views it
/// is asked for.
@MainActor
private final class MutableProvider: @MainActor DMLoadingViewProvider {
    var loadingManagerSettings: DMLoadingManagerSettings = StubDMLoadingManagerSettings(autoHideDelay: .seconds(1))
    var loadingViewSettings: DMProgressViewSettings = DMProgressViewDefaultSettings()
    var errorViewSettings: DMErrorViewSettings = DMErrorDefaultViewSettings()
    var successViewSettings: DMSuccessViewSettings = DMSuccessDefaultViewSettings()
    private(set) var viewRequests: [String] = []

    func getLoadingView() -> some View {
        viewRequests.append("loading")
        return EmptyView()
    }

    func getErrorView(error: Error, onRetry: DMAction?, onClose: DMAction) -> some View {
        viewRequests.append("error")
        return EmptyView()
    }

    func getSuccessView(object: DMLoadableTypeSuccess) -> some View {
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
