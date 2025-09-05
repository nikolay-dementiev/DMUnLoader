//
//  DMUnLoader
//
//  Created by Mykola Dementiev
//

import XCTest
@testable import DMUnLoader

@MainActor
final class StringAndPointersTests: XCTestCase {
    
    // Test case: When the input object is nil
    func testPointerWithNil() {
        let result = String.pointer(nil)
        XCTAssertEqual(result, "nil", "Pointer should return 'nil' when the input object is nil")
    }
    
    // Test case: When the input object is non-nil
    func testPointerWithNonNilObject() {
        let object = NSObject()
        let result = String.pointer(object)
        
        // Ensure the result is not "nil"
        XCTAssertNotEqual(result, "nil", "Pointer should not return 'nil' for a non-nil object")
        
        // Ensure the result is a valid string representation of a memory address
        XCTAssertTrue(result.hasPrefix("0x"), "Pointer string should start with '0x'")
    }
    
    // Test case: Consistency for the same object
    func testPointerConsistency() {
        let object = NSObject()
        let firstResult = String.pointer(object)
        let secondResult = String.pointer(object)
        
        XCTAssertEqual(firstResult, secondResult, "Pointer should consistently return the same value for the same object")
    }
    
    // Test case: Different objects produce different pointers
    func testPointerForDifferentObjects() {
        let object1 = NSObject()
        let object2 = NSObject()
        let result1 = String.pointer(object1)
        let result2 = String.pointer(object2)
        
        XCTAssertNotEqual(result1, result2, "Pointer should return different values for different objects")
    }
}
