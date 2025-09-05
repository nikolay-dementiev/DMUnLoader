//
//  DMUnLoader
//
//  Created by Mykola Dementiev
//

import XCTest
@testable import DMUnLoader
import SwiftUI
import ViewInspector

final class DMRootLoadingModifierTests: XCTestCase {
    
    // MARK: Initialization Tests
    
    @MainActor
    func testInitialization() {
        let globalLoadingStateManager = MockGlobalLoadingStateManager(loadableState: .none)
        let modifier = DMRootLoadingModifier(globalLoadingStateManager: globalLoadingStateManager)
        
        XCTAssertNotNil(modifier.globalLoadingStateManager,
                        "The globalLoadingStateManager should be initialized")
    }
    
    // MARK: Rendering Tests
    
    @MainActor
    func testRendersContainerView() throws {
        let globalLoadingStateManager = MockGlobalLoadingStateManager(loadableState: .none)
        let modifier = DMRootLoadingModifier(globalLoadingStateManager: globalLoadingStateManager)
        
        let view = EmptyView().modifier(modifier)
        
        let containerView = try? view
            .inspect()
            .find(viewWithTag: DMRootLoadingModifierOwnSettings.containerViewTag)
            .zStack()
        XCTAssertNotNil(containerView,
                        "The container view should be rendered")
    }
    
    func testDoesNotRenderBlockingViewWhenNotLoading() throws {
        let globalLoadingStateManager = MockGlobalLoadingStateManager(loadableState: .none)
        // isLoading == false
        
        let modifier = DMRootLoadingModifier(globalLoadingStateManager: globalLoadingStateManager)
        
        let view = EmptyView().modifier(modifier)
        
        let blockingView = try? view
            .inspect()
            .find(viewWithTag: DMRootLoadingModifierOwnSettings.blockingViewTag)
        
        XCTAssertNil(blockingView,
                     "The blocking view should not be rendered when isLoading is false")
    }
    
    func testRendersBlockingViewWhenLoading() throws {
        let globalLoadingStateManager = MockGlobalLoadingStateManager(loadableState: .loading)
        
        let modifier = DMRootLoadingModifier(globalLoadingStateManager: globalLoadingStateManager)
        
        let view = EmptyView().modifier(modifier)
        
        let blockingView = try view
            .inspect()
            .find(viewWithTag: DMRootLoadingModifierOwnSettings.blockingViewTag)
        XCTAssertNotNil(blockingView,
                        "The blocking view should be rendered when isLoading is true")
    }
    
    func testRendersBlockingColorView() throws {
        defer {
            ViewHosting.expel()
        }
        
        let globalLoadingStateManager = MockGlobalLoadingStateManager(loadableState: .loading)
        
        let modifier = DMRootLoadingModifier(globalLoadingStateManager: globalLoadingStateManager)
        
        let view = EmptyView().modifier(modifier)
        
        ViewHosting.host(view: view)
        
        let blockingColorView = try view
            .inspect()
            .find(viewWithTag: DMRootLoadingModifierOwnSettings.blockingColorViewTag)
            .color()
        XCTAssertNotNil(blockingColorView,
                        "The blocking color view should be rendered")
        XCTAssertEqual(try? blockingColorView.value(),
                       Color.gray.opacity(0.001),
                       "The blocking color view should have the correct color with opacity")
    }
    
    func testBlockingViewAllowsHitTesting() throws {
        let globalLoadingStateManager = MockGlobalLoadingStateManager(loadableState: .loading)
        
        let modifier = DMRootLoadingModifier(globalLoadingStateManager: globalLoadingStateManager)
        
        let view = EmptyView().modifier(modifier)
        
        let blockingView = try? view
            .inspect()
            .find(viewWithTag: DMRootLoadingModifierOwnSettings.blockingViewTag)
        
        XCTAssertNotNil(blockingView,
                        "The blocking view should be rendered")
        
        XCTAssertNotNil(blockingView?.allowsHitTesting(),
                        "The blocking view should allow hit testing")
        XCTAssertTrue(blockingView!.isResponsive(),
                      "The blocking view should be responsive")
    }
}
