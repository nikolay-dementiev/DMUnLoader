//
//  DMUnLoader
//
//  Created by Mykola Dementiev
//

import XCTest
@testable import DMUnLoader

final class OptionalProtocolTests: XCTestCase {
    
    // MARK: OptionalProtocol Tests
    
    func testIsSomeValueForSome() {
        let optional: String? = "Hello"
        
        XCTAssertTrue(optional.isSomeValue(),
                      "isSomeValue should return true for a non-nil optional")
    }
    
    func testIsSomeValueForNone() {
        let optional: String? = nil
        
        XCTAssertFalse(optional.isSomeValue(),
                       "isSomeValue should return false for a nil optional")
    }
    
    func testUnwrapValueForSome() {
        let optional: String? = "Hello"
        
        XCTAssertEqual(try? optional.unwrapValue() as? String,
                       "Hello",
                       "unwrapValue should return the unwrapped value")
    }
    
    func testUnwrapValueForNone() {
        let optional: String? = nil
        
        // swiftlint:disable:next assert_throws_error
        XCTAssertThrowsError(try {
            _ = try optional.unwrapValue()
        }(),
                             "unwrapValue should throw an Error for a nil optional")
    }
    
    // MARK: isNilOrEmpty Tests
    
    func testIsNilOrEmptyForNil() {
        let optional: [Int]? = nil
        
        XCTAssertTrue(optional.isNilOrEmpty,
                      "isNilOrEmpty should return true for a nil optional collection")
    }
    
    func testIsNilOrEmptyForEmptyCollection() {
        let optional: [Int]? = []
        
        XCTAssertTrue(optional.isNilOrEmpty,
                      "isNilOrEmpty should return true for an empty optional collection")
    }
    
    func testIsNilOrEmptyForNonEmptyCollection() {
        let optional: [Int]? = [1,
                                2,
                                3]
        
        XCTAssertFalse(optional.isNilOrEmpty,
                       "isNilOrEmpty should return false for a non-empty optional collection")
    }
    
    // MARK: getValueOrNullSting Tests
    
    func testGetValueOrNullStringForSome() {
        let optional: String? = "Hello"
        
        XCTAssertEqual(optional.getValueOrNullSting(),
                       "Hello",
                       "getValueOrNullSting should return the unwrapped value for a non-nil optional")
    }
    
    func testGetValueOrNullStringForNone() {
        let optional: String? = nil
        
        XCTAssertEqual(optional.getValueOrNullSting(),
                       "<null>",
                       "getValueOrNullSting should return '<null>' for a nil optional")
    }
    
    func testGetValueOrNullStringForNestedOptionals() {
        let nestedOptional: String? = "Hello"
        
        let unwrappedOptional: String = nestedOptional.getValueOrNullSting()!
        XCTAssertEqual(unwrappedOptional,
                       "Hello",
                       "getValueOrNullSting should handle nested optionals correctly")
    }
    
    func testGetValueOrNullStringForNilNestedOptionals() {
        let nestedOptional: String? = nil
        
        XCTAssertEqual(nestedOptional.getValueOrNullSting()!,
                       "<null>",
                       "getValueOrNullSting should return '<null>' for a nil nested optional")
    }
}
