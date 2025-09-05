//
//  DMUnLoader
//
//  Created by Mykola Dementiev
//

import XCTest
@testable import DMUnLoader

final class DMLoadableTypeTests: XCTestCase {
    
    // MARK: Raw Representable Tests
    
    func testRawValueForLoading() {
        let loadableType = DMLoadableType.loading
        XCTAssertEqual(loadableType.rawValue,
                       "Loading",
                       "Raw value for .loading should be 'Loading'")
    }
    
    func testRawValueForFailure() {
        let error = NSError(domain: "TestError",
                            code: 1,
                            userInfo: nil)
        let loadableType = DMLoadableType.failure(error: error,
                                                  onRetry: DMButtonAction({}))
        XCTAssertEqual(loadableType.rawValue,
                       "Error: `\(error)`",
                       "Raw value for .failure should include the error description")
    }
    
    func testRawValueForSuccess() {
        let successObject = MockDMLoadableTypeSuccess(description: "Mock Success")
        let loadableType = DMLoadableType.success(successObject)
        XCTAssertEqual(loadableType.rawValue,
                       "Success: `Mock Success`",
                       "Raw value for .success should include the success object's description")
    }
    
    func testRawValueForNone() {
        let loadableType = DMLoadableType.none
        XCTAssertEqual(loadableType.rawValue,
                       "None",
                       "Raw value for .none should be 'None'")
    }
    
    func testInitWithRawValue() {
        XCTAssertNil(DMLoadableType(rawValue: "Loading"),
                     "Initializer should return nil for any raw value")
        XCTAssertNil(DMLoadableType(rawValue: "Error: SomeError"),
                     "Initializer should return nil for any raw value")
        XCTAssertNil(DMLoadableType(rawValue: "Success: SomeSuccess"),
                     "Initializer should return nil for any raw value")
        XCTAssertNil(DMLoadableType(rawValue: "None"),
                     "Initializer should return nil for any raw value")
    }
    
    // MARK: Hashable and Equatable Tests
    
    func testEquatableConformance() {
        let error1 = NSError(domain: "TestError",
                             code: 1,
                             userInfo: nil)
        let error2 = NSError(domain: "TestError",
                             code: 2,
                             userInfo: nil)
        
        let loading1 = DMLoadableType.loading
        let loading2 = DMLoadableType.loading
        
        let failure1 = DMLoadableType.failure(error: error1,
                                              onRetry: DMButtonAction({}))
        let failure2 = DMLoadableType.failure(error: error1,
                                              onRetry: DMButtonAction({}))
        let failure3 = DMLoadableType.failure(error: error2,
                                              onRetry: DMButtonAction({}))
        
        let success1 = DMLoadableType.success(MockDMLoadableTypeSuccess(description: "Mock Success"))
        let success2 = DMLoadableType.success(MockDMLoadableTypeSuccess(description: "Mock Success"))
        let success3 = DMLoadableType.success(MockDMLoadableTypeSuccess(description: "Different Success"))
        
        let none1 = DMLoadableType.none
        let none2 = DMLoadableType.none
        
        XCTAssertEqual(loading1,
                       loading2,
                       "Two .loading instances should be equal")
        XCTAssertEqual(failure1,
                       failure2,
                       "Two .failure instances with the same error should be equal")
        XCTAssertNotEqual(failure1,
                          failure3,
                          "Two .failure instances with different errors should not be equal")
        XCTAssertEqual(success1,
                       success2,
                       "Two .success instances with the same description should be equal")
        XCTAssertNotEqual(success1,
                          success3,
                          "Two .success instances with different descriptions should not be equal")
        XCTAssertEqual(none1,
                       none2,
                       "Two .none instances should be equal")
    }
    
    func testHashableConformance() {
        let error = NSError(domain: "TestError",
                            code: 1,
                            userInfo: nil)
        let successObject = MockDMLoadableTypeSuccess(description: "Mock Success")
        
        let loading = DMLoadableType.loading
        let failure = DMLoadableType.failure(error: error,
                                             onRetry: DMButtonAction({}))
        let success = DMLoadableType.success(successObject)
        let none = DMLoadableType.none
        
        var hasher = Hasher()
        loading.hash(into: &hasher)
        let loadingHash = hasher.finalize()
        
        hasher = Hasher()
        failure.hash(into: &hasher)
        let failureHash = hasher.finalize()
        
        hasher = Hasher()
        success.hash(into: &hasher)
        let successHash = hasher.finalize()
        
        hasher = Hasher()
        none.hash(into: &hasher)
        let noneHash = hasher.finalize()
        
        XCTAssertEqual(loadingHash,
                       loading.rawValue.hashValue,
                       "Hash value for .loading should match its raw value's hash")
        XCTAssertEqual(failureHash,
                       failure.rawValue.hashValue,
                       "Hash value for .failure should match its raw value's hash")
        XCTAssertEqual(successHash,
                       success.rawValue.hashValue,
                       "Hash value for .success should match its raw value's hash")
        XCTAssertEqual(noneHash,
                       none.rawValue.hashValue,
                       "Hash value for .none should match its raw value's hash")
    }
}
