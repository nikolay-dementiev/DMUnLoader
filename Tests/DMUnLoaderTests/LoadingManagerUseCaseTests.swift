//
//  DMUnLoader
//
//  Created by Mykola Dementiev
//

import XCTest

public enum DMLoadableState: Sendable {
    case idle
    case loading
    case success
    case error(Error)
}

public protocol LoadingManager {
    var currentState: DMLoadableState { get }
    func show(state: DMLoadableState)
}

public class LoadingManagerService: LoadingManager {
    public var currentState: DMLoadableState {
        _currentState()
    }
    
    private var _currentState: Atomic<DMLoadableState>
    
    public init(withState state: DMLoadableState = .idle) {
        self._currentState = Atomic(state)
    }
    
    public func show(state: DMLoadableState) {
        self._currentState.mutate { [state] prop in
            prop = state
        }
    }
}

final class LoadingManagerUseCaseTests: XCTestCase {

    func test_init_LoadingManagerInitiatedInIdleState() {
        let sut = LoadingManagerService(withState: .idle)
        XCTAssertEqual(sut.currentState, .idle, "LoadingManager should be initialized in idle state")
        
        let sut2 = LoadingManagerService()
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
        let expectation = XCTestExpectation(description: "States should be displayed in order")
        
        let testConcurrentQueue = DispatchQueue(label: "com.test.concurrentQueue", attributes: .concurrent)

        expectation.expectedFulfillmentCount = 3
        
        testConcurrentQueue.async {
            sut.show(state: .loading)
            expectation.fulfill()
        }
        testConcurrentQueue.asyncAfter(deadline: .now() + 0.01) {
            sut.show(state: .idle)
            expectation.fulfill()
        }
        testConcurrentQueue.asyncAfter(deadline: .now() + 0.02) {
            sut.show(state: .error(
                NSError(
                    domain: "TestError",
                    code: 1
                )
            ))
            expectation.fulfill()
        }
        
        wait(for: [expectation], timeout: 0.3)
        
        XCTAssertEqual(
            sut.states,
            [
                .loading,
                .idle,
                .error(
                    NSError(
                        domain: "TestError",
                        code: 1
                    )
                )
            ],
            "LoadingManager should display states in the order they are received"
        )
    }
    
    // MARK: Helpers
    
    private func makeSUT() -> LoadingManagerSpy {
        LoadingManagerSpy(manager: LoadingManagerService())
    }
    
    private class LoadingManagerSpy: @unchecked Sendable, LoadingManager {
        
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
    }
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
