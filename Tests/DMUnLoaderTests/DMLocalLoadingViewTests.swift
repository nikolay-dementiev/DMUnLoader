//
//  DMUnLoader
//
//  Created by Mykola Dementiev
//

import XCTest
@testable import DMUnLoader
import ViewInspector
import SwiftUI

final class DMLocalLoadingViewTests: XCTestCase {
    
//    @MainActor
//    func testInitialization() {
//        defer {
//            ViewHosting.expel()
//        }
//        
//        // Create mocks
//        let provider = MockDMLoadingViewProvider()
//        let content = { Text("Test Content") }
//        
//        // Initialize DMLocalLoadingView
//        let testView = DMLocalLoadingView(provider: provider, content: content)
//        ViewHosting.host(view: testView)
//        
//        // Inspect the view hierarchy
//        if let expEnvironment = testView.inspection?.inspect({ view in
//            let loadingManagerFromView = try? view.actualView().loadingManager
//            XCTAssertNotNil(loadingManagerFromView,
//                            "DMLoadingManager should be available as the StateObject")
//        }) {
//            wait(for: [expEnvironment], timeout: 0.01)
//        } else {
//            XCTFail("The view should be inspected")
//        }
//    }
    
//    @MainActor
//    func testEnvironmentIntegration() throws {
//        defer {
//            ViewHosting.expel()
//        }
//        
//        // Create mocks
//        let provider = MockDMLoadingViewProvider()
//        let content = { Text("Test Content") }
//        // Create a real object (due to `environment` prop. constraints)
//        let globalManager = GlobalLoadingStateManager()
//        
//        // Initialize DMLocalLoadingView
//        let testView = DMLocalLoadingView(provider: provider, content: content)
//        ViewHosting.host(view: testView
//            .environment(\.globalLoadingManager, globalManager))
//        
//        // Inspect the view hierarchy
//        if let expEnvironment = testView.inspection?.inspect({ view in
//            let globalLoadingManagerFromView = try view.actualView().globalLoadingManager
//            XCTAssertNotNil(globalLoadingManagerFromView,
//                            "GlobalLoadingStateManager should be available in the environment")
//            
//            XCTAssertEqual(globalLoadingManagerFromView?.id,
//                           globalManager.id,
//                           "GlobalLoadingStateManager ids' is not the same in the environment!")
//            
//        }) {
//            wait(for: [expEnvironment], timeout: 0.01)
//        } else {
//            XCTFail("The view should be inspected")
//        }
//    }
    
//    @MainActor
//    func testLifecycleMethods() throws {
//        defer {
//            ViewHosting.expel()
//        }
//        
//        // Create mocks
//        let provider = MockDMLoadingViewProvider()
//        // Create a real object (due to `environment` prop. constraints)
//        let globalManager = GlobalLoadingStateManager()
//        
//        // Initialize DMLocalLoadingView
//        let testView = DMLocalLoadingView(provider: provider) {
//            Text("Test Content")
//        }
//        
//        ViewHosting.host(view: testView
//        .environment(\.globalLoadingManager, globalManager))
//        
//        if let expEnvironment = testView.inspection?.inspect({ view in
//            
//            let loadingManagerFromView = try? view.actualView().loadingManager
//            XCTAssertNotNil(loadingManagerFromView,
//                            "DMLoadingManager should be available as the StateObject")
//            
//            XCTAssertTrue(globalManager.loadableState == .none,
//                          "Global manager should reflect the initial state of the local manager")
//            
//            // Trigger a state change in the local manager
//            loadingManagerFromView!.showLoading()
//            XCTAssertTrue(globalManager.loadableState == .loading,
//                          "Global manager should reflect the loading state of the local manager")
//            
//            // Simulate onDisappear
//            try view.actualView().unsubscribeFromLoadingManager(localManager: loadingManagerFromView!,
//                                                                globalManager: globalManager)
//            loadingManagerFromView!.hide()
//            XCTAssertFalse(globalManager.loadableState == .none,
//                           "Global manager should no longer reflect changes after unsubscribing")
//        }) {
//            wait(for: [expEnvironment], timeout: 0.01)
//        } else {
//            XCTFail("The view should be inspected")
//        }
//    }
    
//    @MainActor
//    func testAutoLoadingModifier() throws {
//        defer {
//            ViewHosting.expel()
//        }
//        
//        // Create mocks
//        let provider = MockDMLoadingViewProvider()
//        // Create a real object (due to `environment` prop. constraints)
//        let globalManager = GlobalLoadingStateManager()
//        
//        // Create a test view
//        let testView = DMLocalLoadingView(provider: provider) {
//            Text("Test Content")
//        }
//        
//        let loadingManagerFromInitView = testView.getLoadingManager()
//        XCTAssertNotNil(loadingManagerFromInitView, ".getLoadingManager() should return a non-nil value")
//        
//        ViewHosting.host(view: testView
//            .environment(\.globalLoadingManager, globalManager))
//        
//        // Inspect the view hierarchy
//        if let expEnvironment = testView.inspection?.inspect({ view in
//            
//            let actualView = try? view.actualView()
//            
//            let loadingManagerFromView = actualView?.loadingManager
//            XCTAssertNotNil(loadingManagerFromView,
//                            "DMLoadingManager should be available as the StateObject")
//            
//            let globalLoadingManagerFromView = actualView?.globalLoadingManager
//            XCTAssertNotNil(globalLoadingManagerFromView,
//                            "GlobalLoadingStateManager should be available in the environment")
//            
//            XCTAssertEqual(globalLoadingManagerFromView?.id,
//                           globalManager.id,
//                           "GlobalLoadingStateManager ids' is not the same in the environment!")
//            
//            let modifier = actualView?.modifier(DMLoadingModifier<MockDMLoadingViewProvider, DMLoadingManager>.self)
//            XCTAssertNotNil(modifier,
//                            "DMLoadingModifier should be applied")
//            
//            let childDMLoadingView = try? view
//                .find(DMLoadingView<MockDMLoadingViewProvider, DMLoadingManager>.self)
//            XCTAssertNotNil(childDMLoadingView, "DMLoadingView should be available in the DMLocalLoadingView.modifier's content")
//            
//            let loadingContentViewFromView = try childDMLoadingView?.parent().zStack().first
//            XCTAssertNotNil(loadingContentViewFromView, "DMLoadingView's content should be available in the ZStack")
//            
//            let isLoading = loadingManagerFromView?.loadableState != DMLoadableType.none
//            XCTAssertEqual(loadingContentViewFromView?.isDisabled(),
//                           isLoading,
//                           "DMLoadingView's content should be disabled when loading (loadableState != .none)!")
//            
//            let correctBlurValue: CGFloat = isLoading ? 2 : 0
//            XCTAssertEqual(try loadingContentViewFromView?.blur().radius,
//                           correctBlurValue,
//                           // swiftlint:disable:next line_length
//                           "DMLoadingView's content `blur` radius should be set to `\(correctBlurValue)` when loading (loadableState != .none)!")
//        }) {
//            wait(for: [expEnvironment], timeout: 0.01)
//        } else {
//            XCTFail("The view should be inspected")
//        }
//    }
    
//#if DEBUG
//    @MainActor
//    func testInspectionMechanism() {
//        // Create mocks
//        let provider = MockDMLoadingViewProvider()
//        let content = { Text("Test Content") }
//        
//        // Initialize DMLocalLoadingView
//        let view = DMLocalLoadingView(provider: provider, content: content)
//        
//        // Verify inspection mechanism
//        XCTAssertNotNil(view.inspection, "Inspection should be available in DEBUG mode for Test target")
//    }
//#endif
}
