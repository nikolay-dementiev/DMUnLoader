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
        
        XCTAssertThrowsError(try {
            _ = try optional.unwrapValue()
        }(),
                             "unwrapValue should throw an Error for a nil optional")
    }
}
