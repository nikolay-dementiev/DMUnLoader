//
//  DMUnLoader
//
//  Created by Mykola Dementiev
//

@testable import DMUnLoader
import XCTest

final class DMAppErrorLocalizedTests: XCTestCase {
    
    // MARK: ResourceError Tests
    
    func testResourceErrorLocalizedDescriptions() {
        let notAvailableError = DMAppError.ResourceError.notAvailable
        XCTAssertEqual(notAvailableError.errorDescription,
                       "The requested resource is not available.")
        
        let underlyingError = NSError(domain: "TestDomain",
                                      code: 1,
                                      userInfo: [NSLocalizedDescriptionKey: "Underlying error"])
        let errorWithError = DMAppError.ResourceError.error(underlyingError)
        XCTAssertEqual(errorWithError.errorDescription, "Underlying error")
    }
    
    // MARK: NetworkError Tests
    
    // swiftlint:disable:next function_body_length
    func testNetworkErrorLocalizedDescriptions() {
        let inaccessibleError = DMAppError.NetworkError.inaccessible
        XCTAssertEqual(
            inaccessibleError.errorDescription,
            "The network is inaccessible. Please check your internet connection."
        )
        
        let urlError = URLError(.notConnectedToInternet)
        let urlErrorCase = DMAppError.NetworkError.urlError(urlError)
        XCTAssertEqual(
            urlErrorCase.errorDescription,
            urlError.localizedDescription
        )
        
        let generalError = NSError(domain: "TestDomain",
                                   code: 1,
                                   userInfo: [NSLocalizedDescriptionKey: "General error"])
        let generalErrorCase = DMAppError.NetworkError.generalError(generalError)
        XCTAssertEqual(generalErrorCase.errorDescription, "General error")
        
        let noResponseError = DMAppError.NetworkError.noResponse
        XCTAssertEqual(
            noResponseError.errorDescription,
            "No response was received from the server."
        )
        
        let invalidResponse = URLResponse(url: URL(string: "http://example.com")!,
                                          mimeType: nil,
                                          expectedContentLength: 0,
                                          textEncodingName: nil)
        let invalidResponseTypeError = DMAppError.NetworkError.invalidResponseType(invalidResponse)
        XCTAssertTrue(
            invalidResponseTypeError.errorDescription?.contains("Invalid response type") == true
        )
        
        let httpResponse = HTTPURLResponse(url: URL(string: "http://example.com")!,
                                           statusCode: 200,
                                           httpVersion: nil,
                                           headerFields: nil)!
        let noResponseDataError = DMAppError.NetworkError.noResponseData(httpResponse)
        XCTAssertEqual(
            noResponseDataError.errorDescription,
            "The server returned an empty response for status code 200."
        )
        
        let endpointResponse = HTTPURLResponse(url: URL(string: "http://example.com")!,
                                               statusCode: 404,
                                               httpVersion: nil,
                                               headerFields: nil)!
        let endpointError = DMAppError.NetworkError.endpointError(endpointResponse, nil)
        XCTAssertEqual(
            endpointError.errorDescription,
            "Endpoint error with status code 404."
        )
        
        let customErrorWithDescription = DMAppError.NetworkError.custom(
            errorCode: 500,
            errorDescription: "Custom error message"
        )
        XCTAssertEqual(
            customErrorWithDescription.errorDescription,
            "Custom error message",
            "Custom error should return the provided error description"
        )
        
        let customErrorWithoutDescription = DMAppError.NetworkError.custom(
            errorCode: 404,
            errorDescription: nil
        )
        XCTAssertEqual(
            customErrorWithoutDescription.errorDescription,
            "A custom network error occurred.",
            "Custom error without description should return the default fallback message"
        )
    }
    
    // MARK: DMAppError Tests
    
    func testDMAppErrorLocalizedDescriptions() {
        let resourceError = DMAppError.resourceError(type: .notAvailable)
        XCTAssertEqual(
            resourceError.errorDescription,
            "The requested resource is not available."
        )
        
        let networkError = DMAppError.network(type: .inaccessible)
        XCTAssertEqual(
            networkError.errorDescription,
            "The network is inaccessible. Please check your internet connection."
        )
        
        let customError = DMAppError.custom("Custom error description")
        XCTAssertEqual(
            customError.errorDescription,
            "Custom error description"
        )
        
        let underlyingError = NSError(domain: "TestDomain",
                                      code: 1,
                                      userInfo: [NSLocalizedDescriptionKey: "Underlying error"])
        let generalError = DMAppError.generalError(underlyingError)
        XCTAssertEqual(generalError.errorDescription, "Underlying error")
    }
    
    // MARK: Test NSError
    
    func testNSErrorConformsToDMError() {
        // Create an NSError instance
        let nsError = NSError(
            domain: "TestDomain",
            code: 123,
            userInfo: [NSLocalizedDescriptionKey: "Test error description"]
        )
        
        // Verify that it conforms to DMError
        XCTAssertTrue(
            (nsError as Any) is (any DMError),
            "NSError should conform to DMError"
        )
    }
    
    // MARK: - Test LocalizedError Implementation
    
    func testNSErrorLocalizedDescription() {
        // Create an NSError instance with a custom localized description
        let nsError = NSError(
            domain: "TestDomain",
            code: 456,
            userInfo: [NSLocalizedDescriptionKey: "Custom error message"]
        )
        
        // Verify that the errorDescription matches the localized description
        XCTAssertEqual(
            nsError.errorDescription,
            "Custom error message",
            "errorDescription should match the provided localized description"
        )
    }
    
    func testNSErrorDefaultLocalizedDescription() {
        // Create an NSError instance without a custom localized description
        let nsError = NSError(domain: "TestDomain", code: 789)
        
        // Verify that the errorDescription falls back to the default description
        XCTAssertNotNil(
            nsError.errorDescription,
            "errorDescription should not be nil"
        )
        
        XCTAssertTrue(
            nsError.errorDescription!.contains("TestDomain"),
            "Default errorDescription should include the domain"
        )
    }
    
    func testNSErrorIntegrationWithDMAppError() {
        // Create an NSError instance
        let nsError = NSError(
            domain: "TestDomain",
            code: 101,
            userInfo: [NSLocalizedDescriptionKey: "Nested error"]
        )
        
        // Wrap the NSError in a DMAppError.generalError
        let dmError = DMAppError.generalError(nsError)
        
        // Verify that the localized description is propagated correctly
        XCTAssertEqual(
            dmError.errorDescription,
            "Nested error",
            "DMAppError should propagate the NSError's localized description"
        )
    }
}
