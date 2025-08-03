//
//  DMUnLoader
//
//  Created by Mykola Dementiev
//

import XCTest
import DMUnLoader

final class LoadingManagerUseCaseTests: XCTestCase {

    func test_init_LoadingManagerInitiatedInIdleState() {
        let sut = DMLoadingManagerService(withState: .idle)
        XCTAssertEqual(sut.currentState, .idle, "LoadingManager should be initialized in idle state")
        
        let sut2 = DMLoadingManagerService()
        XCTAssertEqual(
            sut2.currentState,
            .idle,
            "LoadingManager should be initialized in idle state even if it's not provided explicitly"
        )
        
        let sut3 = makeSUT()
        XCTAssertEqual(sut3.currentState, .idle, "LoadingManager should be initialized in idle state")
    }
    
    func test_states_LoadingManagerIsDisplayesItsStatesInOrderOfIncome() {
        let sut = makeSUT()
        sut.show(state: .loading)
        sut.show(state: .idle)
        
        XCTAssertEqual(
            sut.states,
            [.loading, .idle],
            "LoadingManager should display states in the order they are received"
        )
    }
    
    func test_states_LoadingManagerIsDisplayesItsStatesInOrderOfIncomeInMultithreadingEnviroment() {
        let sut = makeSUT()
        let testConcurrentQueue = DispatchQueue(label: "com.test.concurrentQueue", attributes: .concurrent)
        
        let expectations = UncheckedSendableExpectations()
        let ext1 = XCTestExpectation()
        testConcurrentQueue.async {
            sut.show(state: .loading)
            expectations.completedExpectationInOrder.append(ext1)
        }
        let ext2 = XCTestExpectation()
        testConcurrentQueue.async {
            sut.show(state: .idle)
            expectations.completedExpectationInOrder.append(ext2)
        }
        let ext3 = XCTestExpectation()
        testConcurrentQueue.async {
            sut.show(state: .error(anyError()))
            expectations.completedExpectationInOrder.append(ext3)
        }
        
        wait(for: expectations.completedExpectationInOrder, timeout: 3)
        
        XCTAssertEqual(
            expectations.completedExpectationInOrder,
            [
                ext1, ext2, ext3
            ],
            "LoadingManager should display states in the order they are received"
        )
    }
    
    func test_autoHideDelay_SettingsProvideTwoSecondsDelayByDefault() {
        let sut = makeSUT()
        
        XCTAssertEqual(sut.settings.autoHideDelay,
                       .seconds(2),
                       "Default autoHideDelay should be `2` seconds")
    }
        
    func test_currentState_IfItsNotIdleOrLoadingShouldResetToIdleStateAfterTimeInterval() {
        let secTimeInterval: Double = 0.001
        let sut = makeSUT(settings: DMLoadingManagerConfiguration(autoHideDelay: .seconds(secTimeInterval)))
        
        let states = [
            DMLoadableState.success,
            DMLoadableState.error(anyError())
        ]
            
        states.forEach { state in
            sut.show(state: state)
            
            let exp = XCTestExpectation(description: "Current state should reset to idle after delay")
            DispatchQueue.main.asyncAfter(deadline: .now() + secTimeInterval + 0.005) {
                exp.fulfill()
            }
            
            wait(for: [exp], timeout: secTimeInterval + 0.01)
            
            XCTAssertEqual(
                sut.currentState,
                .idle,
                "Current state `\(sut.currentState)` should reset to idle after delay when showing \(state)"
            )
        }
    }
    
    func test_currentState_IfItsIdleOrLoadingShouldNotResetToIdleStateAfterTimeInterval() {
        let secTimeInterval: Double = 0.001
        let sut = makeSUT(settings: DMLoadingManagerConfiguration(autoHideDelay: .seconds(secTimeInterval)))
        
        let states = [
            DMLoadableState.idle,
            DMLoadableState.loading
        ]
            
        states.forEach { state in
            sut.show(state: state)
            
            let exp = XCTestExpectation(description: "Current state should NOT reset to idle after delay")
            DispatchQueue.main.asyncAfter(deadline: .now() + secTimeInterval + 0.005) {
                exp.fulfill()
            }
            
            wait(for: [exp], timeout: secTimeInterval + 0.01)
            
            XCTAssertEqual(
                sut.currentState,
                state,
                "Current state `\(sut.currentState)` should NOT reset to idle after delay when showing \(state)"
            )
        }
    }
    
    func test_currentState_setIdleStateAfterManagerHide() {
        let sut = makeSUT()
        
        sut.show(state: .loading)
        sut.hide()
        
        XCTAssertEqual(sut.currentState, .idle)
    }
    
    // MARK: - Helpers
    
    private func makeSUT(settings: DMLoadingManagerSettings = DMLoadingManagerConfiguration()) -> LoadingManagerSpy {
        LoadingManagerSpy(manager: DMLoadingManagerService(settings: settings))
    }
    
    private class LoadingManagerSpy: @unchecked Sendable, LoadingManager {
        var settings: DMLoadingManagerSettings {
            manager.settings
        }
        
        var currentState: DMLoadableState {
            manager.currentState
        }
        
        private let manager: LoadingManager
        private(set) var states = [DMLoadableState]()
        
        init(manager: LoadingManager) {
            self.manager = manager
        }
        
        public func show(state: DMLoadableState) {
            manager.show(state: state)
            self.states.append(state)
        }
        
        func hide() {
            manager.hide()
        }
    }
    
    final class UncheckedSendableExpectations: @unchecked Sendable {
        var completedExpectationInOrder = [XCTestExpectation]()
    }
}

func anyError() -> Error {
    NSError(domain: "TestError", code: 0, userInfo: nil)
}

extension DMLoadableState: Equatable {
    public static func == (lhs: DMLoadableState, rhs: DMLoadableState) -> Bool {
        switch (lhs, rhs) {
        case (.idle, .idle):
            return true
        case (.loading, .loading):
            return true
        case (.success, .success):
            return true
        case let (.error(lhsError as NSError), .error(rhsError as NSError)):
            return lhsError.code == rhsError.code && lhsError.domain == rhsError.domain
        default:
            return false
        }
    }
}
