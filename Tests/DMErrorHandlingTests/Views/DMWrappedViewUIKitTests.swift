//
//  DMErrorHandling
//
//  Created by Mykola Dementiev
//

import XCTest
@testable import DMErrorHandling
import SwiftUI
import ViewInspector

final class DMWrappedViewUIKitTests: XCTestCase {
    
    // MARK: - Initialization Tests
    
    @MainActor
    func testInitialization() {
        let mockUIView = MockUIView()
        let wrappedView = DMWrappedViewUIKit(uiView: mockUIView)
        
        XCTAssertNotNil(wrappedView.uiView, "The uiView should be initialized")
        XCTAssertTrue(wrappedView.uiView === mockUIView, "The uiView should match the provided UIView")
    }
    
    // MARK: makeUIView \ updateUIView Tests
    
    @MainActor
    func testMakeAndUpdateUIViewReturnsCorrectView() {
        let exp = XCTestExpectation(description: "extractUIView")
        let mockUIView = MockUIView()
        let sut = DMWrappedViewUIKit(uiView: mockUIView)
        
        DispatchQueue
            .main
            .asyncAfter(deadline: .now() + 0.01) {
            sut.inspect { view in
                let uiView = try view.actualView().uiView()
                XCTAssertNotNil(uiView,
                                "The uiView() method should return the initialized UIView")
                
                XCTAssertTrue(uiView === mockUIView,
                "The uiView() method should return the provided UIView")
                ViewHosting.expel()
                exp.fulfill()
            }
        }
        ViewHosting.host(view: sut)
        defer { ViewHosting.expel() }
        wait(for: [exp], timeout: 0.05)
    }
}
