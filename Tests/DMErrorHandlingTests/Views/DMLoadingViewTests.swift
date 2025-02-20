//
//  DMLoadingViewTests.swift
//  DMErrorHandling
//
//  Created by Nikolay Dementiev on 18.02.2025.
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
        defer {
            ViewHosting.expel()
        }
        
        let loadingManager = MockDMLoadingManager()
        let provider = MockDMLoadingViewProvider()
        let testView = DMLoadingView(loadingManager: loadingManager,
                                     provider: provider)
        
        XCTAssertEqual(loadingManager.loadableState,
                       .none,
                       "Initial state should be .none")
        
        ViewHosting.host(view: testView)
        
        if let expEnvironment = testView.inspection?.inspect({ view in
            let noneStateView = try? view
                .implicitAnyView()
                .find(viewWithTag: DMLoadingViewOwnSettings.emptyViewTag)
            XCTAssertNotNil(noneStateView,
                            "The body should render an EmptyView for .none state")
        }) {
            wait(for: [expEnvironment], timeout: 0.022)
        } else {
            XCTFail("The view should be inspected")
        }
    }
    
    @MainActor
    func testLoadingStateRendersLoadingView() {
        defer {
            ViewHosting.expel()
        }
        
        let loadingManager = MockDMLoadingManager()
        let provider = MockDMLoadingViewProvider()
        let testView = DMLoadingView(loadingManager: loadingManager,
                                     provider: provider)
        
        loadingManager.loadableState = .loading
        XCTAssertEqual(loadingManager.loadableState,
                       .loading,
                       "State should be .loading")
        
        ViewHosting.host(view: testView)
        
        if let expEnvironment = testView.inspection?.inspect({ view in
            let defaultStateView = try? view
                .implicitAnyView()
                .find(viewWithTag: DMLoadingViewOwnSettings.defaultViewTag)
                .zStack()
            XCTAssertNotNil(defaultStateView,
                            "The body should render the default ZStack as a container")
            
            let loadingStateView = try? view
                .implicitAnyView()
                .find(viewWithTag: DMLoadingViewOwnSettings.loadingViewTag)
            XCTAssertNotNil(loadingStateView,
                            "The body should render the Loading view for .loading state")
        }) {
            wait(for: [expEnvironment], timeout: 0.022)
        } else {
            XCTFail("The view should be inspected")
        }
    }
    
    @MainActor
    func testFailureStateRendersErrorView() {
        defer {
            ViewHosting.expel()
        }
        
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
        
        ViewHosting.host(view: testView)
        
        if let expEnvironment = testView.inspection?.inspect({ view in
            let defaultStateView = try? view
                .implicitAnyView()
                .find(viewWithTag: DMLoadingViewOwnSettings.defaultViewTag)
                .zStack()
            XCTAssertNotNil(defaultStateView,
                            "The body should render the default ZStack as a container")
            
            let failureStateView = try? view
                .implicitAnyView()
                .find(viewWithTag: DMLoadingViewOwnSettings.failureViewTag)
            XCTAssertNotNil(failureStateView,
                            "The body should render the ErrorView view for .failure state")
        }) {
            wait(for: [expEnvironment], timeout: 0.022)
        } else {
            XCTFail("The view should be inspected")
        }
    }
    
    @MainActor
    func testSuccessStateRendersSuccessView() {
        defer {
            ViewHosting.expel()
        }
        
        let loadingManager = MockDMLoadingManager()
        let provider = MockDMLoadingViewProvider()
        let testView = DMLoadingView(loadingManager: loadingManager,
                                     provider: provider)
        
        let currentState: DMLoadableType = .success(MockDMLoadableTypeSuccess())
        loadingManager.loadableState = currentState
        
        XCTAssertEqual(loadingManager.loadableState,
                       currentState,
                       "State should be .success")
        
        ViewHosting.host(view: testView)
        
        if let expEnvironment = testView.inspection?.inspect({ view in
            let defaultStateView = try? view
                .implicitAnyView()
                .find(viewWithTag: DMLoadingViewOwnSettings.defaultViewTag)
                .zStack()
            XCTAssertNotNil(defaultStateView,
                            "The body should render the default ZStack as a container")
            
            let successStateView = try? view
                .implicitAnyView()
                .find(viewWithTag: DMLoadingViewOwnSettings.successViewTag)
            XCTAssertNotNil(successStateView,
                            "The body should render the SuccessView view for .success state")
        }) {
            wait(for: [expEnvironment], timeout: 0.022)
        } else {
            XCTFail("The view should be inspected")
        }
    }
    
    // MARK: Interactivity Tests
    
    @MainActor
    func testTapGestureHidesLoadingManager() {
        defer {
            ViewHosting.expel()
        }
        
        let loadingManager = MockDMLoadingManager()
        let provider = MockDMLoadingViewProvider()
        let testView = DMLoadingView(loadingManager: loadingManager,
                                     provider: provider)
        
        let currentState: DMLoadableType = .success(MockDMLoadableTypeSuccess())
        loadingManager.loadableState = currentState
        
        ViewHosting.host(view: testView)
        
        if let expEnvironment = testView.inspection?.inspect({ view in
            let tapGestureView = try? view
                .implicitAnyView()
                .find(viewWithTag: DMLoadingViewOwnSettings.tapGestureViewTag)
            XCTAssertNotNil(tapGestureView,
                            "The body should render a tap gesture view")
            
            XCTAssertNoThrow(try tapGestureView?.callOnTapGesture(),
                             "The view should be able to call the tap gesture")
            
            XCTAssertEqual(loadingManager.loadableState,
                           .none,
                           "The loadingManager should change the state to .none")

        }) {
            wait(for: [expEnvironment], timeout: 0.022)
        } else {
            XCTFail("The view should be inspected")
        }
    }
    
    @MainActor
    func testTapGestureHidesLoadingManagerLoadingState() {
        defer {
            ViewHosting.expel()
        }
        
        let loadingManager = MockDMLoadingManager()
        let provider = MockDMLoadingViewProvider()
        let testView = DMLoadingView(loadingManager: loadingManager,
                                     provider: provider)
        
        let currentState: DMLoadableType = .loading
        loadingManager.loadableState = currentState
        
        ViewHosting.host(view: testView)
        
        if let expEnvironment = testView.inspection?.inspect({ view in
            let tapGestureView = try? view
                .implicitAnyView()
                .find(viewWithTag: DMLoadingViewOwnSettings.tapGestureViewTag)
            XCTAssertNotNil(tapGestureView,
                            "The body should render a tap gesture view")
            
            XCTAssertNoThrow(try tapGestureView?.callOnTapGesture(),
                             "The view should be able to call the tap gesture")
            
            XCTAssertEqual(loadingManager.loadableState,
                           .loading,
                           "The loadingManager should not change the state")
        }) {
            wait(for: [expEnvironment], timeout: 0.022)
        } else {
            XCTFail("The view should be inspected")
        }
    }
}
