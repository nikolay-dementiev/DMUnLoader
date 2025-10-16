//
//  DMUnLoader
//
//  Created by Mykola Dementiev
//

import XCTest
@testable import DMUnLoader
import SwiftUI
import ViewInspector

final class DMLoadingViewTests: XCTestCase {
    
    // MARK: Initialization Tests
    
    @MainActor
    func testInitialization() {
        let loadingManager = MockDMLoadingManager()
        let view = DMLoadingView(loadingManager: loadingManager)
        
        XCTAssertNotNil(view.loadingManager,
                        "The loadingManager should be initialized")
    }
    
    // MARK: State Handling Tests
    
    @MainActor
    func testNoneStateRendersEmptyView() {
        let loadingManager = MockDMLoadingManager()
        let testView = DMLoadingView(loadingManager: loadingManager)
        
        XCTAssertEqual(loadingManager.loadableState,
                       .none,
                       "Initial state should be .none")
        
        let testedView = try? testView.inspect()
        XCTAssertNotNil(testedView, "The view should be rendered")
        let noneStateView = try? testedView?
            .find(viewWithTag: DMLoadingViewOwnSettings.emptyViewTag)
        XCTAssertNotNil(noneStateView,
                        "The body should render an EmptyView for .none state; Instead rendered as `\(type(of: noneStateView))`")
    }
    
    @MainActor
    func testLoadingStateRendersLoadingView() {
        let loadingManager = MockDMLoadingManager()
        let provider = MockDMLoadingViewProvider()
        let testView = DMLoadingView(loadingManager: loadingManager)
        
        let loadableState = DMLoadableType.loading(provider: provider.eraseToAnyViewProvider())
        loadingManager.loadableState = loadableState
        XCTAssertEqual(loadingManager.loadableState,
                       loadableState,
                       "State should be .loading")
        
        let testedView = try? testView.inspect()
        XCTAssertNotNil(testedView, "The view should be rendered")
        let defaultStateView = try? testedView?
            .find(viewWithTag: DMLoadingViewOwnSettings.defaultViewTag)
            .zStack()
        XCTAssertNotNil(defaultStateView,
                        """
                        The body should render the default ZStack as a container;
                        Instead rendered as `\(type(of: defaultStateView))`
                        """)
        
        let loadingStateView = try? testedView?
            .find(viewWithTag: DMLoadingViewOwnSettings.loadingViewTag)
        XCTAssertNotNil(loadingStateView,
                        """
                        The body should render the Loading view for .loading state; 
                        Instead rendered as `\(type(of: loadingStateView))`
                        """)
    }
    
    @MainActor
    func testFailureStateRendersErrorView() {
        let loadingManager = MockDMLoadingManager()
        let provider = MockDMLoadingViewProvider()
        let testView = DMLoadingView(loadingManager: loadingManager)
        
        let currentState: DMLoadableType = .failure(
            error: NSError(domain: "TestError",
                           code: 1,
                           userInfo: nil),
            provider: provider.eraseToAnyViewProvider(),
            onRetry: DMButtonAction({})
        )
        loadingManager.loadableState = currentState
        XCTAssertEqual(loadingManager.loadableState,
                       currentState,
                       "State should be .failure")
        
        let testedView = try? testView.inspect()
        XCTAssertNotNil(testedView, "The view should be rendered")
        
        let defaultStateView = try? testedView?
            .find(viewWithTag: DMLoadingViewOwnSettings.defaultViewTag)
            .zStack()
        XCTAssertNotNil(defaultStateView,
                        """
                        The body should render the default ZStack as a container;
                        Instead rendered as `\(type(of: defaultStateView))`
                        """)
        
        let failureStateView = try? testedView?
            .find(viewWithTag: DMLoadingViewOwnSettings.failureViewTag)
        XCTAssertNotNil(failureStateView,
                        """
                        The body should render the ErrorView view for .failure state;
                        Instead rendered as `\(type(of: failureStateView))`
                        """)
    }
    
    @MainActor
    func testSuccessStateRendersSuccessView() {
        let loadingManager = MockDMLoadingManager()
        let provider = MockDMLoadingViewProvider()
        let testView = DMLoadingView(loadingManager: loadingManager)
        
        let currentState: DMLoadableType = .success(MockDMLoadableTypeSuccess(),
                                                    provider: provider.eraseToAnyViewProvider())
        loadingManager.loadableState = currentState
        
        XCTAssertEqual(loadingManager.loadableState,
                       currentState,
                       "State should be .success")
        
        let testedView = try? testView.inspect()
        XCTAssertNotNil(testedView, "The view should be rendered")
        
        let defaultStateView = try? testedView?
            .find(viewWithTag: DMLoadingViewOwnSettings.defaultViewTag)
            .zStack()
        XCTAssertNotNil(defaultStateView,
                        """
                        The body should render the default ZStack as a container;
                        Instead rendered as `\(type(of: defaultStateView))`
                        """)
        
        let successStateView = try? testedView?
            .find(viewWithTag: DMLoadingViewOwnSettings.successViewTag)
        XCTAssertNotNil(successStateView,
                        """
                        The body should render the SuccessView view for .success state;
                        Instead rendered as `\(type(of: successStateView))`
                        """)
    }
    
    // MARK: Interactivity Tests
    
    @MainActor
    func testTapGestureHidesLoadingManager() {
        let loadingManager = MockDMLoadingManager()
        let provider = MockDMLoadingViewProvider()
        let testView = DMLoadingView(loadingManager: loadingManager)
        
        let currentState: DMLoadableType = .success(
            MockDMLoadableTypeSuccess(),
            provider: provider.eraseToAnyViewProvider()
        )
        loadingManager.loadableState = currentState
        
        let testedView = try? testView.inspect()
        XCTAssertNotNil(testedView, "The view should be rendered")
        
        let tapGestureView = try? testedView?
            .find(viewWithTag: DMLoadingViewOwnSettings.tapGestureViewTag)
        XCTAssertNotNil(tapGestureView,
                        """
                        The body should render a tap gesture view;
                        Instead rendered as `\(type(of: tapGestureView))`
                        """)
        
        XCTAssertNoThrow(try tapGestureView?.callOnTapGesture(),
                         "The view should be able to call the tap gesture")
        
        XCTAssertEqual(loadingManager.loadableState,
                       .none,
                       """
                       The loadingManager should change the state to .none;
                       Instead set`\(loadingManager.loadableState)`
                       """)
    }
    
    @MainActor
    func testTapGestureHidesLoadingManagerLoadingState() {
        let loadingManager = MockDMLoadingManager()
        let provider = MockDMLoadingViewProvider()
        let testView = DMLoadingView(loadingManager: loadingManager)
        
        let currentState = DMLoadableType.loading(provider: provider.eraseToAnyViewProvider())
        loadingManager.loadableState = currentState
        
        let testedView = try? testView.inspect()
        XCTAssertNotNil(testedView, "The view should be rendered")
        let tapGestureView = try? testedView?
            .find(viewWithTag: DMLoadingViewOwnSettings.tapGestureViewTag)
        XCTAssertNotNil(tapGestureView,
                        """
                        The body should render a tap gesture view;
                        Instead rendered as `\(type(of: tapGestureView))`
                        """)
        
        XCTAssertNoThrow(try tapGestureView?.callOnTapGesture(),
                         "The view should be able to call the tap gesture")
        
        XCTAssertEqual(loadingManager.loadableState,
                       currentState,
                       "The loadingManager should not change the state")
    }
}
