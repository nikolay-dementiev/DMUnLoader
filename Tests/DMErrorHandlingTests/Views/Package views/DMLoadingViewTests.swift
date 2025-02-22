//
//  DMErrorHandling
//
//  Created by Mykola Dementiev
//

import XCTest
@testable import DMErrorHandling
import SwiftUI
import ViewInspector

final class DMLoadingViewTests: XCTestCase {
    
    // MARK: Initialization Tests
    
    @MainActor
    func testInitialization() {
        let loadingManager = MockDMLoadingManager()
        let provider = MockDMLoadingViewProvider()
        let view = DMLoadingView(loadingManager: loadingManager,
                                 provider: provider)
        
        XCTAssertNotNil(view.loadingManager,
                        "The loadingManager should be initialized")
        XCTAssertNotNil(view.provider,
                        "The provider should be initialized")
    }
    
    // MARK: State Handling Tests
    
    @MainActor
    func testNoneStateRendersEmptyView() {
        let loadingManager = MockDMLoadingManager()
        let provider = MockDMLoadingViewProvider()
        let testView = DMLoadingView(loadingManager: loadingManager,
                                     provider: provider)
        
        XCTAssertEqual(loadingManager.loadableState,
                       .none,
                       "Initial state should be .none")
        
        let testedView = try? testView.inspect()
        XCTAssertNotNil(testedView, "The view should be rendered")
        let noneStateView = try? testedView?
            .implicitAnyView()
            .find(viewWithTag: DMLoadingViewOwnSettings.emptyViewTag)
        XCTAssertNotNil(noneStateView,
                        "The body should render an EmptyView for .none state")
    }
    
    @MainActor
    func testLoadingStateRendersLoadingView() {
        let loadingManager = MockDMLoadingManager()
        let provider = MockDMLoadingViewProvider()
        let testView = DMLoadingView(loadingManager: loadingManager,
                                     provider: provider)
        
        loadingManager.loadableState = .loading
        XCTAssertEqual(loadingManager.loadableState,
                       .loading,
                       "State should be .loading")
        
        let testedView = try? testView.inspect()
        XCTAssertNotNil(testedView, "The view should be rendered")
        let defaultStateView = try? testedView?
            .implicitAnyView()
            .find(viewWithTag: DMLoadingViewOwnSettings.defaultViewTag)
            .zStack()
        XCTAssertNotNil(defaultStateView,
                        "The body should render the default ZStack as a container")
        
        let loadingStateView = try? testedView?
            .implicitAnyView()
            .find(viewWithTag: DMLoadingViewOwnSettings.loadingViewTag)
        XCTAssertNotNil(loadingStateView,
                        "The body should render the Loading view for .loading state")
    }
    
    @MainActor
    func testFailureStateRendersErrorView() {
        let loadingManager = MockDMLoadingManager()
        let provider = MockDMLoadingViewProvider()
        let testView = DMLoadingView(loadingManager: loadingManager,
                                     provider: provider)
        
        let currentState: DMLoadableType = .failure(error: NSError(domain: "TestError",
                                                                   code: 1,
                                                                   userInfo: nil),
                                                    onRetry: DMButtonAction({}))
        loadingManager.loadableState = currentState
        XCTAssertEqual(loadingManager.loadableState,
                       currentState,
                       "State should be .failure")
        
        let testedView = try? testView.inspect()
        XCTAssertNotNil(testedView, "The view should be rendered")
        
        let testedViewImplicitAnyView = try? testedView?
            .implicitAnyView()
        let defaultStateView = try? testedViewImplicitAnyView?
            .find(viewWithTag: DMLoadingViewOwnSettings.defaultViewTag)
            .zStack()
        XCTAssertNotNil(defaultStateView,
                        "The body should render the default ZStack as a container")
        
        let failureStateView = try? testedViewImplicitAnyView?
            .find(viewWithTag: DMLoadingViewOwnSettings.failureViewTag)
        XCTAssertNotNil(failureStateView,
                        "The body should render the ErrorView view for .failure state")
    }
    
    @MainActor
    func testSuccessStateRendersSuccessView() {
        let loadingManager = MockDMLoadingManager()
        let provider = MockDMLoadingViewProvider()
        let testView = DMLoadingView(loadingManager: loadingManager,
                                     provider: provider)
        
        let currentState: DMLoadableType = .success(MockDMLoadableTypeSuccess())
        loadingManager.loadableState = currentState
        
        XCTAssertEqual(loadingManager.loadableState,
                       currentState,
                       "State should be .success")
        
        let testedView = try? testView.inspect()
        XCTAssertNotNil(testedView, "The view should be rendered")
        
        let defaultStateView = try? testedView?
            .implicitAnyView()
            .find(viewWithTag: DMLoadingViewOwnSettings.defaultViewTag)
            .zStack()
        XCTAssertNotNil(defaultStateView,
                        "The body should render the default ZStack as a container")
        
        let successStateView = try? testedView?
            .implicitAnyView()
            .find(viewWithTag: DMLoadingViewOwnSettings.successViewTag)
        XCTAssertNotNil(successStateView,
                        "The body should render the SuccessView view for .success state")
    }
    
    // MARK: Interactivity Tests
    
    @MainActor
    func testTapGestureHidesLoadingManager() {
        let loadingManager = MockDMLoadingManager()
        let provider = MockDMLoadingViewProvider()
        let testView = DMLoadingView(loadingManager: loadingManager,
                                     provider: provider)
        
        let currentState: DMLoadableType = .success(MockDMLoadableTypeSuccess())
        loadingManager.loadableState = currentState
        
        let testedView = try? testView.inspect()
        XCTAssertNotNil(testedView, "The view should be rendered")
        
        let tapGestureView = try? testedView?
            .implicitAnyView()
            .find(viewWithTag: DMLoadingViewOwnSettings.tapGestureViewTag)
        XCTAssertNotNil(tapGestureView,
                        "The body should render a tap gesture view")
        
        XCTAssertNoThrow(try tapGestureView?.callOnTapGesture(),
                         "The view should be able to call the tap gesture")
        
        XCTAssertEqual(loadingManager.loadableState,
                       .none,
                       "The loadingManager should change the state to .none")
    }
    
    @MainActor
    func testTapGestureHidesLoadingManagerLoadingState() {
        let loadingManager = MockDMLoadingManager()
        let provider = MockDMLoadingViewProvider()
        let testView = DMLoadingView(loadingManager: loadingManager,
                                     provider: provider)
        
        let currentState: DMLoadableType = .loading
        loadingManager.loadableState = currentState
        
        let testedView = try? testView.inspect()
        XCTAssertNotNil(testedView, "The view should be rendered")
        let tapGestureView = try? testedView?
            .implicitAnyView()
            .find(viewWithTag: DMLoadingViewOwnSettings.tapGestureViewTag)
        XCTAssertNotNil(tapGestureView,
                        "The body should render a tap gesture view")
        
        XCTAssertNoThrow(try tapGestureView?.callOnTapGesture(),
                         "The view should be able to call the tap gesture")
        
        XCTAssertEqual(loadingManager.loadableState,
                       .loading,
                       "The loadingManager should not change the state")
    }
}
