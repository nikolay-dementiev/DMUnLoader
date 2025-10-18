//
//  DMUnLoader
//
//  Created by Mykola Dementiev
//

import XCTest
import DMUnLoader
import Combine

final class DMLoadingManagerTests: XCTestCase {
    
    private var cancellables: Set<AnyCancellable> = []
    
    override func tearDown() {
       cancellables.removeAll()
        super.tearDown()
    }
    
    @MainActor
    func testDefaultInitialization() {
        let sut = makeSUT()
        XCTAssertTrue(
            (sut as AnyObject) is (any DMLoadingManagerProtocol),
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
    
    @MainActor
    func testVerifySuccessState() {
        let secondsAutoHideDelay: Double = 0.2
        let settings = LoadingManagerDefaultSettingsTDD(autoHideDelay: .seconds(secondsAutoHideDelay))
        let sut = makeSUT(settings: settings)
        let provider = TestDMLoadingViewProvider()
        let successsMessage = "Any message"
        
        sut.showSuccess(successsMessage, provider: provider)
        
        let expectationSuccess = FulfillmentTestExpectationSpy(
            description: "Loadable state updated to .success"
        )
        let expectationIdle = XCTestExpectation(
            description: "Loadable state updated to .none after auto-hide delay"
        )
        
        observeLoadableState(of: sut) { state in
            if case .success(let message, _) = state {
                XCTAssertEqual(message.description,
                               successsMessage,
                               "loadableState should be updated to .success with the correct message")
                expectationSuccess.fulfill()
            } else if case .none = state, expectationSuccess.isFulfilled {
                expectationIdle.fulfill()
            }
        }
        
        XCTAssertEqual(
            sut.loadableState,
            .success(
                successsMessage,
                provider: provider.eraseToAnyViewProvider()
            ),
            "After calling `showSuccess(_:provider:)`, `loadableState` should be `.success` with the correct message and provider"
        )
        
        wait(
            for: [expectationSuccess],
            timeout: secondsAutoHideDelay
        )
        wait(
            for: [expectationIdle],
            timeout: secondsAutoHideDelay + 0.05
        )
    }
    
    @MainActor
    func testVerifyFailureState() {
        let secondsAutoHideDelay: Double = 0.2
        let settings = LoadingManagerDefaultSettingsTDD(autoHideDelay: .seconds(secondsAutoHideDelay))
        let sut = makeSUT(settings: settings)
        let provider = TestDMLoadingViewProvider()
        
        let errorDescription = "Test Error"
        let error = NSError(
            domain: "TestDomain",
            code: 100500,
            userInfo: [NSLocalizedDescriptionKey: errorDescription]
        )
        
        sut.showFailure(error, provider: provider, onRetry: nil)
        
        let expectationFailure = FulfillmentTestExpectationSpy(
            description: "Loadable state updated to .failure"
        )
        let expectationIdle = XCTestExpectation(
            description: "Loadable state updated to .none after auto-hide delay"
        )
        
        observeLoadableState(of: sut) { state in
            if case .failure(let error, _, _) = state {
                XCTAssertEqual(error.localizedDescription,
                               errorDescription,
                               "loadableState should be updated to .failure with the correct error")
                expectationFailure.fulfill()
            } else if case .none = state,
                        expectationFailure.isFulfilled {
                expectationIdle.fulfill()
            }
        }
        
        XCTAssertEqual(
            sut.loadableState,
            .failure(
                error: error,
                provider: provider.eraseToAnyViewProvider()
            ),
            "After calling `showFailure(_:provider:)`, `loadableState` should be `.failure` with the correct error and provider"
        )
        
        wait(
            for: [expectationFailure],
            timeout: secondsAutoHideDelay
        )
        wait(
            for: [expectationIdle],
            timeout: secondsAutoHideDelay + 0.05
        )
    }
    
    @MainActor
    func testVerifyHideState() {
        let secondsAutoHideDelay: Double = 0.2
        let settings = LoadingManagerDefaultSettingsTDD(autoHideDelay: .seconds(secondsAutoHideDelay))
        let sut = makeSUT(settings: settings)
        
        let provider = TestDMLoadingViewProvider()
        
        sut.showLoading(provider: provider)
        
        let expectationIdle = FulfillmentTestExpectationSpy(
            description: "Loadable state updated to .none after hide() call"
        )
        let expectationAfterwordsIdle = XCTestExpectation(
            description: "Loadable state remains .none (and doesn't chnaged) after hide() call"
        )
        expectationAfterwordsIdle.isInverted = true
        
        observeLoadableState(of: sut) { state in
            if case .none = state {
                expectationIdle.fulfill()
            } else {
                if expectationIdle.isFulfilled {
                    expectationAfterwordsIdle.fulfill()
                }
            }
        }
        
        sut.hide()
        
        XCTAssertEqual(
            sut.loadableState,
            .none,
            "After calling `hide()`, `loadableState` should be `.none`"
        )
        wait(
            for: [expectationIdle],
            timeout: secondsAutoHideDelay
        )
        wait(
            for: [expectationAfterwordsIdle],
            timeout: secondsAutoHideDelay + 0.2
        )
    }
    
    @MainActor
    func testLoadingManagerConformsToObservableObject() {
        let secondsAutoHideDelay: Double = 0.03
        let settings = LoadingManagerDefaultSettingsTDD(autoHideDelay: .seconds(secondsAutoHideDelay))
        let sut = makeSUT(settings: settings)
        
        // Check if LoadingManager conforms to ObservableObject
        XCTAssertTrue((sut as Any) is (any ObservableObject), "LoadingManager should conform to ObservableObject")
        
        let expectationIdle = FulfillmentTestExpectationSpy(
            description: "Loadable state updated to .none after hide() call"
        )
        
        observeLoadableState(of: sut) { state in
            expectationIdle.fulfill()
        }
        
        sut.hide()
        
        wait(
            for: [expectationIdle],
            timeout: secondsAutoHideDelay
        )
    }
    
    @MainActor
    func testVerifyAutoHideDelayBehavior() {
        let secondsAutoHideDelay: Double = 0.2
        let settings = LoadingManagerDefaultSettingsTDD(autoHideDelay: .seconds(secondsAutoHideDelay))
        let sut = makeSUT(settings: settings)
        let provider = TestDMLoadingViewProvider()
        
        let expectationStateSuccessChange = FulfillmentTestExpectationSpy(
            description: "Loadable state did NOT auto-hide before the specified delay"
        )
        expectationStateSuccessChange.isInverted = true
        let expectationIdle = XCTestExpectation(
            description: "Loadable state updated to .none after hide() call"
        )
        
        sut.showSuccess(
            "Some success message",
            provider: provider
        )
        observeLoadableState(of: sut) { state in
            if case .success = state {
                return
            } else if case .none = state,
                        !expectationStateSuccessChange.isFulfilled {
                expectationIdle.fulfill()
            }
            
            expectationStateSuccessChange.fulfill()
        }
        
        wait(
            for: [expectationStateSuccessChange],
            timeout: secondsAutoHideDelay-0.01
        )
        wait(
            for: [expectationIdle],
            timeout: secondsAutoHideDelay+0.01
        )
    }
    
    // MARK: Helpers

    @MainActor
    private func observeLoadableState(
        of sut: DMLoadingManager,
        handler: @escaping (DMLoadableType) -> Void
    ) {
        sut
            .$loadableState
            .sink(receiveValue: handler)
            .store(in: &cancellables)
    }
    
    @MainActor
    private func makeSUT<S>(
        settings: S,
        file: StaticString = #filePath,
        line: UInt = #line
    ) -> DMLoadingManager where S: DMLoadingManagerSettings {
        let loadingManager = DMLoadingManager(
            state: .none,
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
                         line: UInt = #line) -> DMLoadingManager {
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

private final class TestDMLoadingViewProvider: DMLoadingViewProviderProtocol {
    public var id: UUID = UUID()
}
