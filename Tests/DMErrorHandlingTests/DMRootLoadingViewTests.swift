//
//  DMRootLoadingViewTests.swift
//  DMErrorHandling
//
//  Created by Nikolay Dementiev on 12.02.2025.
//

import SwiftUI
import XCTest
@testable import DMErrorHandling
import ViewInspector

@MainActor // Ensure all tests run on the main actor
class DMRootLoadingViewTests: XCTestCase {
    
    func testInitialization() throws {
        // Create a mock content view that takes a GlobalLoadingStateManager
        let contentView = { (manager: GlobalLoadingStateManager) -> Text in
            Text("Test Content")
        }
        
        // Initialize DMRootLoadingView with the mock content
        let hostingViewController = makeTestRootView(content: contentView)
        let rootLoadingView = hostingViewController.rootView
        
        // Ensure that the view initializes without crashing
        XCTAssertNotNil(rootLoadingView)
    }
    
    func testGlobalLoadingStateManagerIsPassedToContent() throws {
        // Create an expectation to wait for the view lifecycle
        let expectation = XCTestExpectation(description: "GlobalLoadingStateManager passed to content")
        
        // Create a mock content view that captures the GlobalLoadingStateManager
        var capturedManager: GlobalLoadingStateManager?
        let contentView = { (manager: GlobalLoadingStateManager) -> Text in
            capturedManager = manager
            return Text("Test Content")
        }
        
        // Create the root view
        let hostingController = makeTestRootView(content: contentView)
        
        // Use ViewInspector to inspect and render the view hierarchy
        Task {
            do {
                // Inspect the root view to trigger rendering
                let inspectedView = try hostingController.rootView.inspect()
                
                // Find the Text view inside DMRootLoadingView
                _ = try inspectedView.find(ViewType.Text.self)
                
                // Verify that the GlobalLoadingStateManager was passed to the content
                XCTAssertNotNil(capturedManager, "GlobalLoadingStateManager was not passed to the content")
                expectation.fulfill()
            } catch {
                XCTFail("Failed to inspect view: \(error)")
            }
        }
        
        // Wait for the expectation to be fulfilled
        wait(for: [expectation], timeout: 0.2)
    }
    
    func testRootLoadingModifierIsApplied() throws {
        // Create a mock content view
        let contentView = { (manager: GlobalLoadingStateManager) -> Text in
            Text("Test Content")
        }
        
        let hostingViewController = makeTestRootView(content: contentView)
        let rootLoadingView = hostingViewController.rootView
        
        do {
            // Use ViewInspector to inspect the view hierarchy
            let inspectedView = try rootLoadingView.inspect().find(ViewType.Text.self)
            let text = try inspectedView.string()
            
            // Ensure that the text "Test Content" is present
            XCTAssertEqual(text, "Test Content")
        } catch {
            XCTFail("Failed to inspect view: \(error)")
        }
    }
    
    func testGetLoadingManagerReturnsObject() throws {
        // Create a mock content view
        let contentView = { (manager: GlobalLoadingStateManager) -> Text in
            Text("Test Content")
        }
        
        // Create the root view
        let hostingViewController = makeTestRootView(content: contentView)
        let rootLoadingView = hostingViewController.rootView
        
        do {
            // Inspect the root view to trigger rendering
            let inspectedView = try rootLoadingView.inspect().find(ViewType.View<DMRootLoadingView<Text>>.self)
            
            // Access the DMRootLoadingView instance
            guard let rootLoadingView = try? inspectedView.actualView() else {
                XCTFail("Failed to extract DMRootLoadingView from the inspected view")
                return
            }
            
            // Call getLoadingManager and verify it returns a non-nil object
            let loadingManager = rootLoadingView.getLoadingManager()
            XCTAssertNotNil(loadingManager, "getLoadingManager did not return a valid GlobalLoadingStateManager object")
        } catch {
            XCTFail("Failed to inspect view: \(error)")
        }
    }
    
    // Helper function to create a test-specific root view using UIHostingController
    private func makeTestRootView<Content: View>(
        content: @escaping (GlobalLoadingStateManager) -> Content
    ) -> UIHostingController<DMRootLoadingView<Content>> {
        // Create the DMRootLoadingView
        let rootView = DMRootLoadingView(content: content)
        
        // Embed the view in a UIHostingController
        let hostingController = UIHostingController(rootView: rootView)
        
        // Trigger the view lifecycle by accessing the view property
        _ = hostingController.view
        
        return hostingController
    }
}
