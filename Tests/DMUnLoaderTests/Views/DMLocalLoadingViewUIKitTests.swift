//
//  DMUnLoader
//
//  Created by Mykola Dementiev
//

import XCTest
@testable import DMUnLoader
import UIKit
import SwiftUI

final class DMLocalLoadingViewUIKitTests: XCTestCase {
    
    // MARK: Initialization Tests
    
    @MainActor
    func testInitialization() {
        let mockUIKitView = MockUIKitView()
        let mockProvider = MockDMLoadingViewProvider()
        let loadingManager = MockDMLoadingManager()
        
        let view = DMLocalLoadingViewUIKit(provider: mockProvider,
                                           innerView: mockUIKitView,
                                           loadingManager: loadingManager)
        
        XCTAssertNotNil(view.loadingManager,
                        "The loadingManager should be initialized")
        XCTAssertNotNil(view.subviews.first,
                      "The hosting controller's view should be initiated")
    }
    
    @MainActor
    func testInitializationFromCoder() {
        let view = DMLocalLoadingViewUIKit<
            UIView,
            MockDMLoadingViewProvider,
            MockDMLoadingManager
        >(coder: NSCoder())
        
        XCTAssertNil(view,
                    "Failed to initialize view from coder")
    }
    
    // MARK: Hosting Controller Setup Tests
    
    @MainActor
    func testHostingControllerViewIsAddedAsSubview() {
        let mockUIKitView = MockUIKitView()
        let mockProvider = MockDMLoadingViewProvider()
        let loadingManager = MockDMLoadingManager()
        
        let view = DMLocalLoadingViewUIKit(provider: mockProvider,
                                           innerView: mockUIKitView,
                                           loadingManager: loadingManager)
        
        let hostingView = view
            .subviews
            .first
        XCTAssertNotNil(hostingView,
                        "The hosting controller's view should not be nil")
    }
    
    @MainActor
    func testControllerViewHasCorrectConstraints() {
        let mockUIKitView = MockUIKitView()
        let mockProvider = MockDMLoadingViewProvider()
        let loadingManager = MockDMLoadingManager()
        
        let view = DMLocalLoadingViewUIKit(provider: mockProvider,
                                           innerView: mockUIKitView,
                                           loadingManager: loadingManager)
        view.layoutIfNeeded()
        
        XCTAssertEqual(view.constraints.count,
                       4,
                       """
                        The hosting view should have 4 constraints (top,
                        bottom,
                        leading,
                        trailing)
                        """)
        XCTAssertTrue(view
            .constraints
            .contains(where: { $0.firstAttribute == .top && $0.constant == 0 }),
                      "The top constraint should be set")
        XCTAssertTrue(view
            .constraints
            .contains(where: { $0.firstAttribute == .bottom && $0.constant == 0 }),
                      "The bottom constraint should be set")
        XCTAssertTrue(view
            .constraints
            .contains(where: { $0.firstAttribute == .leading && $0.constant == 0 }),
                      "The leading constraint should be set")
        XCTAssertTrue(view
            .constraints
            .contains(where: { $0.firstAttribute == .trailing && $0.constant == 0 }),
                      "The trailing constraint should be set")
    }
}
