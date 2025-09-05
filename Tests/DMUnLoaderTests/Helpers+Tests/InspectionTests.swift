//
//  DMUnLoader
//
//  Created by Mykola Dementiev
//

import XCTest
@testable import DMUnLoader
import Combine
import SwiftUI

final class InspectionTests: XCTestCase {
    
    var cancellables: Set<AnyCancellable>!
    
    override func setUp() {
        super.setUp()
        cancellables = []
    }
    
    override func tearDown() {
        cancellables = nil
        var schemaArguments = SchemaArguments()
        schemaArguments.resetSettingToDefault()
        
        super.tearDown()
    }
    
    // MARK: Inspection Class Tests
    
    func testInitialization() {
        let inspection = Inspection<Text>()
        
        XCTAssertNotNil(inspection.notice,
                        "The notice property should be initialized")
        XCTAssertTrue(inspection.callbacks.isEmpty,
                      "The callbacks dictionary should be empty after initialization")
    }
    
    func testVisitInvokesCallback() {
        let inspection = Inspection<Text>()
        let expectation = XCTestExpectation(description: "Callback invoked")
        let testLine: UInt = 42
        let testView = Text("Test View")
        
        inspection.callbacks[testLine] = { view in
            XCTAssertEqual(view,
                           testView,
                           "The received view should match the test view")
            expectation.fulfill()
        }
        
        inspection.visit(testView,
                         testLine)
        
        wait(for: [expectation],
             timeout: 1.0)
        XCTAssertTrue(inspection.callbacks.isEmpty,
                      "The callback should be removed after execution")
    }
    
    func testVisitWithNonExistentLine() {
        let inspection = Inspection<Text>()
        let testLine: UInt = 42
        let testView = Text("Test View")
        
        inspection.visit(testView,
                         testLine)
        
        XCTAssertTrue(inspection.callbacks.isEmpty,
                      "No callbacks should be invoked or added for a non-existent line")
    }
    
    // MARK: Extensions Tests
    
    @MainActor
    func testGetInspectionIfAvailableWhenEnabled() {
        var schemaArguments = SchemaArguments()
        schemaArguments.currentProcessInfoProvider = MockProcessInfoProvider(arguments: ["--enable-inspection"])
        
        let inspectionForModifier = MockViewModifier.getInspectionIfAvailable()
        let inspectionForView = Text.getInspectionIfAvailable()
        
        XCTAssertNotNil(inspectionForModifier,
                        "Inspection should be available for ViewModifier when enabled")
        XCTAssertNotNil(inspectionForView,
                        "Inspection should be available for View when enabled")
    }
    
    @MainActor
    func testGetInspectionIfAvailableWhenDisabled() {
        var schemaArguments = SchemaArguments()
        schemaArguments.currentProcessInfoProvider = MockProcessInfoProvider(arguments: ["XXX23"])
        
        let inspectionForModifier = MockViewModifier.getInspectionIfAvailable()
        let inspectionForView = Text.getInspectionIfAvailable()
        
        XCTAssertNil(inspectionForModifier,
                     "Inspection should not be available for ViewModifier when disabled")
        XCTAssertNil(inspectionForView,
                     "Inspection should not be available for View when disabled")
    }
}
