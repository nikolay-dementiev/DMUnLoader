//
//  DMUnLoader
//
//  Created by Mykola Dementiev
//

import XCTest
@testable import DMUnLoader
import Combine

struct LoadingManagerDefaultSettingsTDD: DMLoadingManagerSettings {
    let autoHideDelay: Duration
    
    init(autoHideDelay: Duration = .seconds(2)) {
        self.autoHideDelay = autoHideDelay
    }
}

final class LoadingManagerTDD: DMLoadingManagerProtocol {
    @Published var loadableState: DMLoadableType
    
    var settings: DMLoadingManagerSettings
    
    private var inactivityTimerCancellable: AnyCancellable?
    
    init(
        loadableState: DMLoadableType,
        settings: DMLoadingManagerSettings
    ) {
        self.loadableState = loadableState
        self.settings = settings
    }
    
    convenience init() {
        self.init(
            loadableState: .none,
            settings: LoadingManagerDefaultSettingsTDD()
        )
    }
    
    @MainActor
    func showLoading<PR>(provider: PR) where PR: DMLoadingViewProviderProtocol {
        loadableState = .loading(
            provider: provider.eraseToAnyViewProvider()
        )
    }
    
    @MainActor
    func showSuccess<PR>(
        _ message: DMLoadableTypeSuccess,
        provider: PR
    ) where PR: DMLoadingViewProviderProtocol {
        
        startInactivityTimer()
        
        loadableState = .success(
            message,
            provider: provider.eraseToAnyViewProvider()
        )
    }
    
    @MainActor
    func showFailure<PR>(
        _ error: any Error,
        provider: PR,
        onRetry: (DMAction)?
    ) where PR: DMLoadingViewProviderProtocol {
        
    }
    
    func hide() {
        
    }
    
    // MARK: Timer Management
    
    private func startInactivityTimer() {
        stopInactivityTimer()
        
        inactivityTimerCancellable = Deferred {
            Future<Void, Never> { promise in
                promise(.success(()))
            }
        }
        .delay(for: .seconds(settings.autoHideDelay.timeInterval),
               scheduler: RunLoop.main)
        .sink(receiveValue: { [weak self] _ in
            self?.loadableState = .none
        })
    }
    
    private func stopInactivityTimer() {
        inactivityTimerCancellable?.cancel()
        inactivityTimerCancellable = nil
    }
}

@MainActor
final class DMLoadingManagerTestTDD: XCTestCase {
    
    private var cancellables: Set<AnyCancellable> = []
    
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
        let expectationIdle = FulfillmentTestExpectationSpy(
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
    
    // MARK: - Helpers

    private func observeLoadableState(
        of sut: LoadingManagerTDD,
        handler: @escaping (DMLoadableType) -> Void
    ) {
        sut
            .$loadableState
            .sink(receiveValue: handler)
            .store(in: &cancellables)
    }
    
    private func makeSUT<S>(settings: S) -> LoadingManagerTDD where S: DMLoadingManagerSettings {
        LoadingManagerTDD(
            loadableState: .none,
            settings: settings
        )
    }
    
    private func makeSUT() -> LoadingManagerTDD {
        makeSUT(settings: LoadingManagerDefaultSettingsTDD())
    }
}

final class TestDMLoadingViewProvider: DMLoadingViewProviderProtocol {
    public var id: UUID = UUID()
}

final class FulfillmentTestExpectationSpy: XCTestExpectation {
    private(set) var currentFulfillmentCount: Int = 0
    
    var isFulfilled: Bool {
        currentFulfillmentCount > 0
    }
    
    override func fulfill() {
        currentFulfillmentCount += 1
        super.fulfill()
    }
}
