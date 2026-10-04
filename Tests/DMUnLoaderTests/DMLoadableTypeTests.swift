//
//  DMUnLoader
//
//  Created by Mykola Dementiev
//

import XCTest
@testable import DMUnLoader

final class DMLoadableTypeTests: XCTestCase {
    
    // MARK: Raw Representable Tests
    
    @MainActor
    func testRawValueForLoading() {
        let loadableType = DMLoadableType.loading(
            provider: StubDMLoadingViewProvider().eraseToAnyViewProvider()
        )
        XCTAssertEqual(loadableType.rawValue,
                       "Loading",
                       "Raw value for .loading should be 'Loading'")
    }
    
    @MainActor
    func testRawValueForFailure() {
        let error = NSError(domain: "TestError",
                            code: 1,
                            userInfo: nil)
        let loadableType = DMLoadableType.failure(
            error: error,
            provider: StubDMLoadingViewProvider().eraseToAnyViewProvider(),
            onRetry: DMButtonAction({})
        )
        XCTAssertEqual(loadableType.rawValue,
                       "Error: `\(error)`",
                       "Raw value for .failure should include the error description")
    }
    
    @MainActor func testRawValueForSuccess() {
        let successObject = StubDMLoadableTypeSuccess(description: "Mock Success")
        let loadableType = DMLoadableType.success(
            successObject,
            provider: StubDMLoadingViewProvider().eraseToAnyViewProvider()
        )
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
    
    @MainActor
    // swiftlint:disable:next function_body_length
    func testEquatableConformance() {
        let error1 = NSError(domain: "TestError",
                             code: 1,
                             userInfo: nil)
        let error2 = NSError(domain: "TestError",
                             code: 2,
                             userInfo: nil)
        
        let provider = StubDMLoadingViewProvider().eraseToAnyViewProvider()
        let retry = DMButtonAction({})

        let loading1 = DMLoadableType.loading(provider: provider)
        let loading2 = DMLoadableType.loading(provider: provider)

        let failure1 = DMLoadableType.failure(
            error: error1,
            provider: provider,
            onRetry: retry
        )
        let failure2 = DMLoadableType.failure(
            error: error1,
            provider: provider,
            onRetry: retry
        )
        let failure3 = DMLoadableType.failure(
            error: error2,
            provider: provider,
            onRetry: retry
        )
        
        let success1 = DMLoadableType.success(
            StubDMLoadableTypeSuccess(description: "Mock Success"),
            provider: provider
        )
        let success2 = DMLoadableType.success(
            StubDMLoadableTypeSuccess(description: "Mock Success"),
            provider: provider
        )
        let success3 = DMLoadableType.success(
            StubDMLoadableTypeSuccess(description: "Different Success"),
            provider: provider
        )
        
        let none1 = DMLoadableType.none
        let none2 = DMLoadableType.none
        
        XCTAssertEqual(loading1,
                       loading2,
                       "Two .loading instances should be equal")
        XCTAssertEqual(failure1,
                       failure2,
                       "Two .failure instances with the same error and retry action should be equal")
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
}
