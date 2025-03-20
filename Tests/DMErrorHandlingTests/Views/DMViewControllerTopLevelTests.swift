//
//  DMErrorHandling
//
//  Created by Mykola Dementiev
//

import XCTest
@testable import DMErrorHandling
import Combine
import UIKit

final class DMViewControllerTopLevelTests: XCTestCase {
    
    override func tearDown() {
        super.tearDown()
        
        MainActor.assumeIsolated {
            let globalLoadingStateManager = GlobalLoadingStateManager()
            let firsVCSubscriber = MockSubscriberVC(manager: globalLoadingStateManager)
            firsVCSubscriber.cancellableTopLevelView = []
            firsVCSubscriber.subscribedObjects.removeAllObjects()
            firsVCSubscriber.subscribedObjects = NSHashTable<AnyObject>(options: .weakMemory)
        }
    }
    
    // MARK: Tests for cancellableTopLevelView
    
    @MainActor
    func testCancellableTopLevelViewAddsNewSubscriptions() {
        
        let globalLoadingStateManager = GlobalLoadingStateManager()
        
        let firsVCSubscriber = MockSubscriberVC(manager: globalLoadingStateManager)
        firsVCSubscriber.callSubscribeToLoadingStateChange()
        let secondVCSubscriber = MockSubscriberVC(manager: globalLoadingStateManager)
        secondVCSubscriber.callSubscribeToLoadingStateChange()
        
        XCTAssertEqual(
            firsVCSubscriber.cancellableTopLevelView.count,
            2,
            "The global cancellable set should contain all unique cancellables"
        )
        XCTAssertEqual(
            secondVCSubscriber.cancellableTopLevelView.count,
            2,
            "The global cancellable set should contain all unique cancellables"
        )
    }
    
    @MainActor
    func testCancellableTopLevelViewDoesNotAddDuplicates() {
        
        let globalLoadingStateManager = GlobalLoadingStateManager()
        
        let firsVCSubscriber = MockSubscriberVC(manager: globalLoadingStateManager)
        firsVCSubscriber.callSubscribeToLoadingStateChange()
        firsVCSubscriber.callSubscribeToLoadingStateChange()
        firsVCSubscriber.callSubscribeToLoadingStateChange()
        
        XCTAssertEqual(
            firsVCSubscriber.cancellableTopLevelView.count,
            1,
            "he global cancellable set should not contain duplicate cancellables"
        )
    }
    
    // MARK: Tests for subscribeToLoadingStateChange
    
    @MainActor
    func testSubscribeToLoadingStateChangeHandlesStateUpdates() {
        
        let globalLoadingStateManager = GlobalLoadingStateManager()
        
        let firsVCSubscriber = MockSubscriberVC(manager: globalLoadingStateManager)
        firsVCSubscriber.callSubscribeToLoadingStateChange()
        
        globalLoadingStateManager.loadableState = .loading
        
        let exp = XCTestExpectation(description: "StateChangeBlock")
        firsVCSubscriber.handleLoadingStateChangeBlock = { [unowned firsVCSubscriber] state in
            guard state == .loading else {
                return
            }
            defer {
                exp.fulfill()
                firsVCSubscriber.handleLoadingStateChangeBlock = nil
            }
            
            XCTAssertEqual(
                state,
                .loading,
                "The view controller should handle the updated loadableState"
            )
        }
        
        wait(for: [exp], timeout: 0.005)
    }
    
    @MainActor
    func testSubscribeToLoadingStateChangeHandlesMultipleStateUpdates() {
        let globalLoadingStateManager = GlobalLoadingStateManager()
        
        let firsVCSubscriber = MockSubscriberVC(manager: globalLoadingStateManager)
        firsVCSubscriber.callSubscribeToLoadingStateChange()
        
        globalLoadingStateManager.loadableState = .loading
        globalLoadingStateManager.loadableState = .success(MockDMLoadableTypeSuccess())
        let failureState: DMLoadableType = .failure(error: NSError(domain: "TestError",
                                                                   code: 1,
                                                                   userInfo: nil),
                                                    onRetry: DMButtonAction {})
        globalLoadingStateManager.loadableState = failureState
        
        let exp = XCTestExpectation(description: "StateChangeBlock")
        firsVCSubscriber.handleLoadingStateChangeBlock = { state in
            guard state == failureState else {
                exp.fulfill()
                return
            }
        }
        
        wait(for: [exp], timeout: 0.005)
        
        XCTAssertEqual(
            firsVCSubscriber.stateFromManager,
            failureState,
            "The view controller should handle the latest loadableState"
        )
    }
}

// MARK: - Helpers

final private class MockSubscriberVC: UIViewController, @preconcurrency DMViewControllerTopLevel {
    private(set) weak var globalLoadingManager: GlobalLoadingStateManager!
    // var cancellableTopLevelView: Set<AnyCancellable> = []
    
    internal var stateFromManager: DMLoadableType?
    internal var handleLoadingStateChangeBlock: ((DMLoadableType) -> Void)?
    
    internal init(manager: GlobalLoadingStateManager) {
        self.globalLoadingManager = manager
        super.init(nibName: nil, bundle: nil)
    }
    
    internal func callSubscribeToLoadingStateChange() {
        subscribeToLoadingStateChange(from: globalLoadingManager)
    }
   
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    @MainActor
    func handleLoadingStateChange(_ state: DMLoadableType) {
        handleLoadingStateChangeBlock?(state)
        self.stateFromManager = state
    }
}
