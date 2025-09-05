//
//  DMUnLoader
//
//  Created by Mykola Dementiev
//

import SwiftUI
import XCTest
@testable import DMUnLoader
import ViewInspector

@MainActor // Ensure all tests run on the main actor
final class DMRootLoadingViewTests: XCTestCase {
    
    func testInitialization() throws {
        defer {
            ViewHosting.expel()
        }
        // Create a mock content view that takes a GlobalLoadingStateManager
        let contentView = { (manager: GlobalLoadingStateManager) -> Text in
            Text("Test Content")
        }
        
        // Initialize DMRootLoadingView with the mock content
        let rootLoadingView = makeTestRootView(content: contentView)
        
        // Ensure that the view initializes without crashing
        XCTAssertNotNil(rootLoadingView)
    }
    
    func testGlobalLoadingStateManagerIsPassedToContent() throws {
        defer {
            ViewHosting.expel()
        }
        // Create a mock content view that captures the GlobalLoadingStateManager
        var capturedManager: GlobalLoadingStateManager?
        let contentView = { (manager: GlobalLoadingStateManager) -> Text in
            capturedManager = manager
            return Text("Test Content")
        }
        
        // Create the root view
        let rootLoadingView = makeTestRootView(content: contentView)
        
        // Use ViewInspector to inspect and render the view hierarchy
        // Inspect the root view to trigger rendering
        let inspectedView = try rootLoadingView.inspect()
        
        // Find the Text view inside DMRootLoadingView
        _ = try inspectedView
            .find(ViewType.Text.self)
        
        // Verify that the GlobalLoadingStateManager was passed to the content
        XCTAssertNotNil(capturedManager, "GlobalLoadingStateManager was not passed to the content")
    }
    
    func testRootLoadingModifierIsApplied() throws {
        defer {
            ViewHosting.expel()
        }
        // Create a mock content view
        let contentView = { (manager: GlobalLoadingStateManager) -> Text in
            Text("Test Content")
        }
        
        let rootLoadingView = makeTestRootView(content: contentView)
        
        let inspectedView = try rootLoadingView
            .inspect()
            .find(ViewType.Text.self)
        let text = try inspectedView.string()
        
        // Ensure that the text "Test Content" is present
        XCTAssertEqual(text, "Test Content")
    }
    
    func testGetLoadingManagerReturnsObject() throws {
        defer {
            ViewHosting.expel()
        }
        // Create a mock content view
        let contentView = { (manager: GlobalLoadingStateManager) -> Text in
            Text("Test Content")
        }
        
        // Create the root view
        let rootLoadingView = makeTestRootView(content: contentView)
        
        // Inspect the root view to trigger rendering
        let inspectedView = try rootLoadingView.inspect().find(ViewType.View<DMRootLoadingView<Text>>.self)
        
        // Access the DMRootLoadingView instance
        let rootLoadingFromView = try? inspectedView.actualView()
        XCTAssertNotNil(rootLoadingFromView, "Failed to extract DMRootLoadingView from the inspected view")
        
        // Call getLoadingManager and verify it returns a non-nil object
        let loadingManager = rootLoadingFromView?.getLoadingManager()
        XCTAssertNotNil(loadingManager, "getLoadingManager did not return a valid GlobalLoadingStateManager object")
    }
    
    // Helper function to create a test-specific root view using UIHostingController
    private func makeTestRootView<Content: View>(
        content: @escaping (GlobalLoadingStateManager) -> Content
    ) -> DMRootLoadingView<Content> {
        // Create the DMRootLoadingView
        let rootView = DMRootLoadingView(content: content)
        
        ViewHosting.host(view: rootView)
        
        return rootView
    }
}
