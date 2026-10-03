//
//  DMUnLoader
//
//  Created by Mykola Dementiev
//

import XCTest
import DMUnLoader

final class DMLoadingManagerTests: XCTestCase {
    
    @MainActor
    func testDefaultInitialization() {
        let sut = makeSUT()
        XCTAssertTrue(
            (sut as AnyObject) is (any DMLoadingManager),
            "LoadingManager should conform to DMLoadingManagerProtocol"
        )
        
        XCTAssertEqual(
            sut.loadableState,
            .none,
            "Default loadableState should be `.none`"
        )
        
        XCTAssertTrue(
            sut.settings is LoadingManagerDefaultSettingsTDD,
            "Default settings should be an instance of LoadingManagerDefaultSettingsTDD"
        )
    }
    
    @MainActor
    func testVerifyLoadingState() {
        let sut = makeSUT()
        let provider = TestDMLoadingViewProvider()
        
        sut.showLoading(provider: provider)
        
        XCTAssertEqual(
            sut.loadableState,
            .loading(
                provider: provider.eraseToAnyViewProvider()
            ),
            "After calling `showLoading(provider:)`, `loadableState` should be `.loading` with the correct provider"
        )
    }

    /// The public initializer runs the auto-hide on the real run loop. Time is bounded from
    /// one side only, so a slow machine cannot fail the test.
    @MainActor
    func test_publicInit_withASuccessOrAFailure_hidesByItselfOnceTheDelayHasPassed() {
        let provider = TestDMLoadingViewProvider().eraseToAnyViewProvider()
        let states: [DMLoadableType] = [
            .success("done", provider: provider),
            .failure(error: DMAppError.custom("failed"), provider: provider, onRetry: nil)
        ]

        for state in states {
            let sut = makeSUT(state: state, settings: LoadingManagerDefaultSettingsTDD(autoHideDelay: .milliseconds(50)))
            XCTAssertEqual(sut.loadableState, state, "the initial \(state.rawValue) shows until the delay has passed")
            let hidden = expectation(description: "the initial \(state.rawValue) hides by itself")
            let subscription = sut.$loadableState.sink { newState in
                if newState == .none {
                    hidden.fulfill()
                }
            }

            wait(for: [hidden], timeout: 0.05 + TestTiming.callbackAllowance)
            subscription.cancel()
        }
    }

    // MARK: Helpers

    @MainActor
    private func makeSUT<S>(
        state: DMLoadableType = .none,
        settings: S,
        file: StaticString = #filePath,
        line: UInt = #line
    ) -> DMLoadingManagerMain where S: DMLoadingManagerSettings {
        let loadingManager = DMLoadingManagerMain(
            state: state,
            settings: settings
        )
        
        trackForMemoryLeaks(
            loadingManager,
            file: file,
            line: line
        )
        
        return loadingManager
    }
    
    @MainActor
    private func makeSUT(file: StaticString = #filePath,
                         line: UInt = #line) -> DMLoadingManagerMain {
        makeSUT(
            settings: LoadingManagerDefaultSettingsTDD(),
            file: file,
            line: line
        )
    }
}

// MARK: - Helpers; Supports

private struct LoadingManagerDefaultSettingsTDD: DMLoadingManagerSettings {
    let autoHideDelay: Duration
    
    init(autoHideDelay: Duration = .seconds(2)) {
        self.autoHideDelay = autoHideDelay
    }
}

private final class TestDMLoadingViewProvider: DMLoadingViewProvider {
    public var id: UUID = UUID()
}
