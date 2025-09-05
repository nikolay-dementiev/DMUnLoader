//
//  DMUnLoader
//
//  Created by Mykola Dementiev
//

import XCTest
@testable import DMUnLoader
import UIKit
import SwiftUI

final class DMRootViewControllerUIKitTests: XCTestCase {
    
    // MARK: Initialization Tests
    
    @MainActor
    func testInitialization() {
        let mockContentView = MockContentView()
        let viewController = DMRootViewControllerUIKit(contentView: mockContentView)
        
        XCTAssertNotNil(viewController,
                        "The DMRootViewControllerUIKit should be initialized")
    }
    
    // MARK: View Lifecycle Tests
    
    @MainActor
    func testViewDidLoadAddsHostingControllerAsChild() {
        let mockContentView = MockContentView()
        let viewController = DMRootViewControllerUIKit(contentView: mockContentView)
        
        // Trigger viewDidLoad
        _ = viewController.view
        
        XCTAssertEqual(viewController.children.count,
                       1,
                       "The hosting controller should be added as a child")
        XCTAssertTrue(viewController.children.first
                      is UIHostingController<DMRootLoadingView<DMWrappedViewUIKit<MockContentView>>>,
                      "The child should be a UIHostingController")
    }
    
    @MainActor
    func testHostingControllerViewIsProperlyConfigured() {
        let mockContentView = MockContentView()
        let viewController = DMRootViewControllerUIKit(contentView: mockContentView)
        
        // Trigger viewDidLoad
        _ = viewController.view
        
        // Access the hosting controller
        guard let hostingController = viewController.children.first else {
            XCTFail("The hosting controller should be initialized")
            return
        }
        
        XCTAssertEqual(hostingController.view.frame,
                       viewController.view.bounds,
                       "The hosting controller's view should match the parent view's bounds")
        XCTAssertEqual(hostingController.view.autoresizingMask,
                       [.flexibleWidth,
                        .flexibleHeight],
                       "The hosting controller's view should have flexible resizing")
    }
    
    // MARK: Loading Manager Binding Tests
    
    @MainActor
    func testGetLoadingManagerReturnsNotNilInstance() {
        let mockContentView = MockContentView()
        let viewController = DMRootViewControllerUIKit(contentView: mockContentView)
        
        let rootContentView = viewController.rootContentView
        XCTAssertTrue((rootContentView as Any) is DMRootLoadingView<DMWrappedViewUIKit<MockContentView>>,
                      "The rootContentView should be a DMRootLoadingView")
        
        let loadingManager = viewController.getLoadingManager()
        XCTAssertNotNil(loadingManager,
                        "The getLoadingManager property should return non nil GlobalLoadingStateManager instance")
    }
    
    @MainActor
    func testGetLoadingManagerReturnsNotNilInstance1() {
        let mockContentView = MockContentView()
        let rootContentView = DMRootLoadingView { _ in
            // Using UIKit Views as Content for Root SwiftUI Views
            DMWrappedViewUIKit(uiView: mockContentView)
        }
        
        let viewController = DMRootViewControllerUIKit(rootContentView: rootContentView)
        
        XCTAssertTrue(rootContentView.id == viewController.rootContentView.id,
                      "The rootContentView's id should be the same as the one passed as parameter")
    }
    
    @MainActor
    func testInitWithCoder() {
        let viewController = DMRootViewControllerUIKit(coder: NSCoder())
        
        XCTAssertNil(viewController,
                     "The init(coder:) initializer should not succeed")
    }
    
    // MARK: Mock Dependencies
    
    final class MockContentView: UIView {}
}
