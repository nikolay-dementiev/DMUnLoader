//
//  DMUnLoader
//
//  Created by Mykola Dementiev
//

import SwiftUI
import XCTest
@testable import DMUnLoader
import ViewInspector

@MainActor
final class ExtensionViewTests: XCTestCase {
    
//    func testAutoLoadingWithNoneInitialState() throws {
//        try checkAutoLoading(loadableState: .none)
//    }
//    
//    func testAutoLoadingWithLoadingInitialState() throws {
//        try checkAutoLoading(loadableState: .loading)
//    }
    
//    func testAutoLoadingRealObjects() throws {
//        defer {
//            ViewHosting.expel()
//        }
//        
//        // Create objects
//        let provider = DefaultDMLoadingViewProvider()
//        let globalManager = GlobalLoadingStateManager()
//        
//        // Create a test view
//        let testView = DMLocalLoadingView(provider: provider,
//                                          content: {
//            Text("DMLocalLoadingView test content")
//        })
//        
//        ViewHosting.host(view: testView
//            .environment(\.globalLoadingManager, globalManager))
//        
//        // Inspect the view hierarchy
//        if let expEnvironment = testView.inspection?.inspect(after: 0.01, { view in
//            
//            let loadingManagerFromView = try? view.actualView().loadingManager
//            XCTAssertNotNil(loadingManagerFromView,
//                            "DMLoadingManager should be available as the StateObject")
//            
//            let globalLoadingManagerFromView = try view.actualView().globalLoadingManager
//            XCTAssertNotNil(globalLoadingManagerFromView,
//                            "GlobalLoadingStateManager should be available in the environment")
//            
//            XCTAssertEqual(globalLoadingManagerFromView?.id,
//                           globalManager.id,
//                           "GlobalLoadingStateManager ids' is not the same in the environment!")
//            
//            let modifier = try? view.actualView().modifier(DMLoadingModifier<DefaultDMLoadingViewProvider, DMLoadingManager>.self)
//            XCTAssertNotNil(modifier,
//                            "DMLoadingModifier should be applied")
//            // TODO: inspect DMLoadingModifier
//            // self.checkDMLoadingModifier(modifier: modifier, loadingManager: loadingManagerFromView!)
//            
//        }) {
//            wait(for: [expEnvironment], timeout: 0.015)
//        } else {
//            XCTFail("The view should be inspected")
//        }
//    }
            
    private func checkAutoLoading(loadableState: DMLoadableType) throws {
        defer {
            ViewHosting.expel()
        }
        
        // Create mocks
        let loadingManager = MockDMLoadingManager(loadableState: loadableState)
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
        
        let loadingModifier = DMLoadingModifier(loadingManager: loadingManager,
                                                provider: provider)
        ViewHosting.host(view: testView
            .autoLoading(loadingManager,
                         provider: provider,
                         modifier: loadingModifier))
        wait(for: [expEnvironment], timeout: 0.02)
        
        if let expModifier = loadingModifier.inspection?.inspect(after: 0.02, { [unowned self] modifier in
            try self.checkDMLoadingModifier(modifier: modifier, loadingManager: loadingManager)
        }) {
            wait(for: [expModifier], timeout: 0.08)
        } else {
            XCTFail("The view should be inspected")
        }
    }
    
    private func checkDMLoadingModifier<Provider: DMLoadingViewProviderProtocol, LM: DMLoadingManagerInteralProtocol>
    (modifier: InspectableView<ViewType.ViewModifier<DMLoadingModifier<Provider, LM>>>,
     loadingManager: LM,
     file: StaticString = #filePath,
     line: UInt = #line) throws {
        let loadingManagerFromModifier = try modifier.actualView().loadingManager
        // modifier.viewModifierContent()
        
        XCTAssertNotNil(loadingManagerFromModifier,
                        "DMLoadingManager should be available in the modifier",
                        file: file,
                        line: line)
        
        XCTAssertEqual(loadingManagerFromModifier.id,
                       loadingManager.id,
                       "DMLoadingManager ids' is not the same in the modifier!",
                       file: file,
                       line: line)
        
        let childDMLoadingView = try? modifier
            .find(DMLoadingView<MockDMLoadingViewProvider, MockDMLoadingManager>.self)
            .actualView()
        XCTAssertNotNil(childDMLoadingView, "DMLoadingView should be available in the modifier's content", file: file, line: line)
        XCTAssertEqual(childDMLoadingView?.loadingManager.id,
                       loadingManager.id,
                       "DMLoadingManager ids' is not the same in the DMLoadingView!",
                       file: file,
                       line: line)
        
        let loadingContentViewFromModifier = try modifier.zStack().first
        let isLoading = loadingManagerFromModifier.loadableState != .none
        XCTAssertEqual(loadingContentViewFromModifier?.isDisabled(),
                       isLoading,
                       "DMLoadingView's content should be disabled when loading (loadableState != .none)!",
                       file: file,
                       line: line)
        
        let correctBlurValue: CGFloat = isLoading ? 2 : 0
        XCTAssertEqual(try loadingContentViewFromModifier?.blur().radius,
                       correctBlurValue,
                       // swiftlint:disable:next line_length
                       "DMLoadingView's content `blur` radius should be set to `\(correctBlurValue)` when loading (loadableState != .none)!",
                       file: file,
                       line: line)
    }
}

// MARK: - Helpers

// for details, check it out: https://github.com/nalexn/ViewInspector/blob/0.10.2/guide.md

private struct EnvironmentAutoLoadingTestView: View {
    
    @EnvironmentObject var loadingManager: MockDMLoadingManager
    @EnvironmentObject var provider: MockDMLoadingViewProvider
    
    internal let inspection = Inspection<Self>()
    
    var body: some View {
        Text("Test EnvironmentAutoLoadingTestView")
            .onReceive(inspection.notice) { self.inspection.visit(self, $0) }
    }
}
