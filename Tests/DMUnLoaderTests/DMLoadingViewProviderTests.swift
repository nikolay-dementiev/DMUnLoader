//
//  DMUnLoader
//
//  Created by Mykola Dementiev
//

import XCTest
@testable import DMUnLoader
import SwiftUI

final class DMLoadingViewProviderTests: XCTestCase {
    
    // MARK: DefaultDMLoadingViewProvider Tests
    
    func testDefaultDMLoadingViewProviderInitialization() {
        let provider = DefaultDMLoadingViewProvider()
        
        XCTAssertNotNil(provider.id,
                        "ID should not be nil")
        XCTAssertEqual(provider.id.uuidString.count,
                       36,
                       "ID should be a valid UUID")
    }
    
    @MainActor
    func testDefaultLoadingView() {
        let provider = DefaultDMLoadingViewProvider()
        let loadingViewWrappedInAnyView = provider.getLoadingView()
        
        do {
            let loadingView: DMProgressView = try castView(loadingViewWrappedInAnyView)
            
            XCTAssertTrue((loadingView as Any) is DMProgressView,
                          """
                          Default loading view should be an instance of type: `MProgressView`
                          but it is `\(type(of: loadingView))` instead!
                          """)
        } catch {
            XCTFail("""
            Failed to cast the default loading view to `DMProgressView`.
            Error: \(error.localizedDescription)
            """)
        }
    }
    
    @MainActor
    func testDefaultErrorView() throws {
        let provider = DefaultDMLoadingViewProvider()
        let error = NSError(domain: "TestError",
                            code: 1,
                            userInfo: nil)
        let onCloseAction: DMAction = DMButtonAction {}
        let errorViewWrappedInAnyView = provider.getErrorView(error: error,
                                                              onRetry: nil,
                                                              onClose: onCloseAction)
        let errorView: DMErrorView = try castView(errorViewWrappedInAnyView)
        
        XCTAssertTrue((errorView as Any) is DMErrorView,
                      "Default error view should be an instance of DMErrorView")
    }
    
    @MainActor
    func testDefaultSuccessView() throws {
        let provider = DefaultDMLoadingViewProvider()
        let successObject = MockDMLoadableTypeSuccess()
        let successViewWrappedInAnyView = provider.getSuccessView(object: successObject)
        let successView: DMSuccessView = try castView(successViewWrappedInAnyView)
        
        XCTAssertTrue((successView as Any) is DMSuccessView,
                      "Default success view should be an instance of DMSuccessView")
    }
    
    @MainActor
    func testDefaultSettings() {
        let provider = DefaultDMLoadingViewProvider()
        
        XCTAssertTrue(provider.loadingManagerSettings is DMLoadingManagerDefaultSettings,
                      "Default loading manager settings should be an instance of DMLoadingManagerDefaultSettings")
        XCTAssertTrue(provider.loadingViewSettings is DMLoadingDefaultViewSettings,
                      "Default loading view settings should be an instance of DMLoadingDefaultViewSettings")
        XCTAssertTrue(provider.errorViewSettings is DMErrorDefaultViewSettings,
                      "Default error view settings should be an instance of DMErrorDefaultViewSettings")
        XCTAssertTrue(provider.successViewSettings is DMSuccessDefaultViewSettings,
                      "Default success view settings should be an instance of DMSuccessDefaultViewSettings")
    }
    
    // MARK: Hashable and Equatable Tests
    
    func testEquatableConformance() {
        let provider1 = DefaultDMLoadingViewProvider()
        let provider2 = DefaultDMLoadingViewProvider()
        
        XCTAssertNotEqual(provider1,
                          provider2,
                          "Two providers with different IDs should not be equal")
    }
    
    func testHashableConformance() {
        let provider = DefaultDMLoadingViewProvider()
        var hasher = Hasher()
        provider.hash(into: &hasher)
        let hashValue = hasher.finalize()
        
        XCTAssertEqual(hashValue,
                       provider.id.hashValue,
                       "Hash value should match the ID's hash value")
    }
    
    // MARK: - Custom Implementation Tests
    
    @MainActor
    func testCustomImplementation() throws {
        final class CustomProvider: DMLoadingViewProviderProtocol {
            let id = UUID()
            
            @MainActor
            func getLoadingView() -> some View {
                MockDMSuccessViewTest()
            }
            
            @MainActor
            func getErrorView(error: Error,
                              onRetry: DMAction?,
                              onClose: DMAction) -> some View {
                MockDMErrorViewTest()
            }
            
            @MainActor
            func getSuccessView(object: DMLoadableTypeSuccess) -> some View {
                MockDMSuccessViewTest()
            }
        }
        
        let provider = CustomProvider()
        
        let loadingView: MockDMSuccessViewTest = try castView(provider
            .getLoadingView()
        )
        let errorView: MockDMErrorViewTest = try castView(provider
            .getErrorView(error: NSError(domain: "TestError",
                                         code: 1,
                                         userInfo: nil),
                          onRetry: nil,
                          onClose: DMButtonAction({}))
        )
        
        let successView: MockDMSuccessViewTest = try castView(provider
            .getSuccessView(object: MockDMLoadableTypeSuccess())
        )
        
        XCTAssertTrue((loadingView as Any) is MockDMSuccessViewTest,
                      "Custom loading view should be an instance of Text")
        XCTAssertTrue((errorView as Any) is MockDMErrorViewTest,
                      "Custom error view should be an instance of Image")
        XCTAssertTrue((successView as Any) is MockDMSuccessViewTest,
                      "Custom success view should be an instance of Text")
    }
}

// MARK: - Helpers

extension DMLoadingViewProviderTests {
    func castView<T: View>(_ viewToCast: some View) throws -> T {
        
        guard let viewToCast = viewToCast as? T else {
            let requestedView = try viewToCast
                .inspect()
                .view(T.self)
                .actualView()
            
            return requestedView
        }
        
        return viewToCast
    }
}
