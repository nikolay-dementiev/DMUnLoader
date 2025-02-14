//
//  Test.swift
//  DMErrorHandling
//
//  Created by Nikolay Dementiev on 13.02.2025.
//

import SwiftUI
import XCTest
@testable import DMErrorHandling
import ViewInspector

@MainActor
final class ExtensionViewTests: XCTestCase {
    
    func testAutoLoading() throws {
        
        defer {
            ViewHosting.expel()
        }
        
        // Create mocks
        let loadingManager = MockDMLoadingManager()
        let provider = MockDMLoadingViewProvider()
        
        // Create a test view
        let testView = EnvironmentAutoLoadingTestView()
        
        // Inspect the view hierarchy
        let expEnvironment = testView.inspection.inspect { view in
            
            let loadingManagerFromView = try view.actualView().loadingManager
            XCTAssertNotNil(loadingManagerFromView,
                            "DMLoadingManager should be available in the environment")
            
            let providerFromView = try view.actualView().provider
            XCTAssertNotNil(providerFromView,
                            "DMLoadingViewProvider should be available in the environment")
            
            XCTAssertEqual(loadingManagerFromView.id,
                           loadingManager.id,
                           "DMLoadingManager ids' is not the same in the environment!")
            
            XCTAssertEqual(providerFromView.id,
                           provider.id, 
                           "DMLoadingViewProvider ids' is not the same in the environment!")
        }
        
//        let loadingModifier = DMLoadingModifier(loadingManager: loadingManager,
//                                                provider: provider)
        let inspectionModifier = InspectionModifier()

        ViewHosting.host(view: testView
            .autoLoading(loadingManager,
                         provider: provider)
                .modifier(inspectionModifier))
        
        wait(for: [expEnvironment], timeout: 0.1)
        
//        testView.inspect().
        
        let expModifier = inspectionModifier.inspection.inspect(after: 0.1) { modifier in
            
            // XCTAssertEqual(try modifier.viewModifierContent().padding(.top), 15)
//            modifier.actualView()
//            let dd = 0
//            let loadingManagerFromModifier = try modifier.actualView().loadingManager
//            XCTAssertNotNil(loadingManagerFromModifier, "DMLoadingManager should be available in the modifier")
//            
//            XCTAssertEqual(loadingManagerFromModifier.id,
//                           loadingManager.id,
//                           "DMLoadingManager ids' is not the same in the modifier!")
        }
        
        wait(for: [expModifier], timeout: 0.2)
    }
    
    func testSubscribeToGlobalLoadingManagers() {
        
        let provider = MockDMLoadingViewProvider()
        let localManager = DMLoadingManager(state: .none, settings: provider.loadingManagerSettings)
        let globalManager = GlobalLoadingStateManager()
        
        // Create mocks
        /*
        let localManager = MockDMLoadingManager()
        let globalManager = MockGlobalLoadingStateManager(loadableState: .none,
                                                          subscribeToLoadingManagers: { managers in
        },
                                                          unsubscribeFromLoadingManager: { manager in
            
        })
        */

        // Call the function
        Text("Test View").subscribeToGloabalLoadingManagers(localManager: localManager, globalManager: globalManager)

        // Verify subscription
        XCTAssertFalse(globalManager.isLoading, "Global manager should reflect the initial state of the local manager")
        
        // Trigger a state change in the local manager
        localManager.showLoading()
        
        XCTAssertTrue(globalManager.isLoading, "Global manager should reflect the loading state of the local manager")
    }
    
    func testUnsubscribeFromLoadingManager() {
        // Create mocks
        /*
        let localManager = MockDMLoadingManager()
        let globalManager = MockGlobalLoadingStateManager()
        */
        
        let provider = MockDMLoadingViewProvider()
        let localManager = DMLoadingManager(state: .none, settings: provider.loadingManagerSettings)
        let globalManager = GlobalLoadingStateManager()

        // Subscribe first
        globalManager.subscribeToLoadingManagers(localManager)
        XCTAssertTrue(globalManager.isLoading == false, "Global manager should reflect the initial state of the local manager")
        
        // Trigger a state change in the local manager
        localManager.showLoading()
        XCTAssertTrue(globalManager.isLoading, "Global manager should reflect the loading state of the local manager")

        // Unsubscribe
        let lastGlobalManagerStatusBeforeUnscribe = globalManager.isLoading
        Text("Test View").unsubscribeFromLoadingManager(localManager: localManager, globalManager: globalManager)
        
        // Trigger another state change in the local manager
        localManager.hide()
        XCTAssertEqual(lastGlobalManagerStatusBeforeUnscribe,
                       globalManager.isLoading,
                       "Global manager should no longer reflect changes after unsubscribing")
        
        XCTAssertNotEqual(localManager.loadableState,
                          globalManager.loadableState,
                          "Global manager and Local manager statuses can't be the same after unsubscribing")
    }
    
    func testUnsubscribeFromLoadingManagerWithoutGlobalManager() {
        // Create mocks
        let localManager = MockDMLoadingManager()
        let globalManager: MockGlobalLoadingStateManager? = nil

        // Call the function without a global manager
        Text("Test View").unsubscribeFromLoadingManager(localManager: localManager,
                                                        globalManager: globalManager)

        // No crash should occur, and a log message should be printed
        // You can use a logging framework or XCTestExpectation to capture the log message if needed.
    }

    func testSubscribeToGlobalLoadingManagersWithoutGlobalManager() {
        // Create mocks
        let localManager = MockDMLoadingManager()
        let globalManager = MockGlobalLoadingStateManager(loadableState: .none,
                                                          subscribeToLoadingManagers: { managers in
        },
                                                          unsubscribeFromLoadingManager: { manager in
            
        })
        
        // Call the function without a global manager
        Text("Test View").subscribeToGloabalLoadingManagers(localManager: localManager,
                                                            globalManager: globalManager)

        // No crash should occur, and a log message should be printed
        // You can use a logging framework or XCTestExpectation to capture the log message if needed.
    }
    
//    func testRootLoading() throws {
//        // Create a mock global manager
////        let globalManager = MockGlobalLoadingStateManager(loadableState: .none,
////                                                          subscribeToLoadingManagers: { managers in
////        },
////                                                          unsubscribeFromLoadingManager: { manager in
////            
////        })
//        
//        let globalManager = GlobalLoadingStateManager()
//
//        // Create a test view
//        let testView = Text("Test View")
//            .rootLoading(globalManager: globalManager)
//
//        // Inspect the view hierarchy
//        let inspectedView = try testView.inspect()
//
//        // Check if the global manager is available in the environment
//        let environmentGlobalManager: GlobalLoadingStateManager? = try inspectedView.actualView().environmentObject()
//        XCTAssertNotNil(environmentGlobalManager, "GlobalLoadingStateManager should be available in the environment")
//
//        // Check if the modifier is applied
//        let modifier = try inspectedView.find(ViewType.Modifier<DMRootLoadingModifier>.self)
//        XCTAssertNotNil(modifier, "DMRootLoadingModifier should be applied")
//    }
}


//https://github.com/nalexn/ViewInspector/blob/0.10.2/guide.md

private struct EnvironmentAutoLoadingTestView: View {
    
    @EnvironmentObject var loadingManager: MockDMLoadingManager
    @EnvironmentObject var provider: MockDMLoadingViewProvider
    
    internal let inspection = Inspection<Self>()
    
    var body: some View {
        Text("Test EnvironmentAutoLoadingTestView")
            .onReceive(inspection.notice) { self.inspection.visit(self, $0) }
    }
}
