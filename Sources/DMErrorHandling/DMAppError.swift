//
//  DMErrorHandling
//
//  Created by Mykola Dementiev
//

import Foundation

/// A protocol representing an error type that conforms to both `Error` and `LocalizedError`.
/// This allows errors to provide localized descriptions for user-facing messages.
public protocol DMError: Error, LocalizedError {
}

/// An enumeration representing various types of application-specific errors.
/// Conforms to `DMError` and provides localized descriptions for each case.
public enum DMAppError: DMError {
    
    /// Indicates an error related to resource availability or access.
    /// - Parameter type: The specific type of resource error.
    case resourceError(type: ResourceError)
    
    /// Indicates an error related to network operations.
    /// - Parameter type: The specific type of network error.
    case network(type: NetworkError)
    
    /// Represents a custom error with an optional description.
    /// - Parameter errorDescription: A custom error message.
    case custom(_ errorDescription: String?)
    
    /// Wraps a general error conforming to `DMError`.
    /// - Parameter error: The underlying error.
    case generalError(DMError)
}

/// Extensions for `DMAppError` to define associated types and localized error descriptions.
public extension DMAppError {
    
    /// An enumeration representing errors related to resource access.
    enum ResourceError: DMError {
        /// Indicates that the requested resource is not available.
        case notAvailable
        
        /// Wraps an underlying error related to resource access.
        /// - Parameter error: The underlying error.
        case error(Error)
    }
}

/// Conformance to `LocalizedError` for `DMAppError`.
extension DMAppError: LocalizedError {
    
    /// Provides a localized description for the error.
    /// - Returns: A string describing the error in a user-friendly manner.
    public var errorDescription: String? {
        switch self {
        case .resourceError(let type):
            return type.localizedDescription
        case .network(let type):
            return type.localizedDescription
        case .custom(let errorDescription):
            return errorDescription
        case .generalError(let error):
            return String(describing: error.localizedDescription)
        }
    }
}

// MARK: Connection Errors

/// An enumeration representing errors related to network operations.
/// It includes pass-through `URLError` cases and custom network-related errors.
extension DMAppError {
    public enum NetworkError: DMError {
        
        /// Indicates that the network is inaccessible due to poor conditions after multiple retries.
        case inaccessible
        
        /// Wraps a `URLError` from `URLSession`.
        /// - Parameter urlError: The underlying `URLError`.
        case urlError(URLError)
        
        /// Wraps a general `Error` object that is not a `URLError`.
        /// - Parameter error: The underlying error.
        case generalError(Swift.Error)
        
        /// Indicates that no response was received from the server.
        case noResponse
        
        /// Indicates that the response type is invalid (not an `HTTPURLResponse`).
        /// - Parameter response: The invalid response.
        case invalidResponseType(URLResponse)
        
        /// Indicates that the server returned an empty response body for a valid status code.
        /// - Parameter httpResponse: The `HTTPURLResponse` with no data.
        case noResponseData(HTTPURLResponse)
        
        /// Indicates an endpoint error with a status code of 400 or higher.
        /// - Parameters:
        ///   - httpResponse: The `HTTPURLResponse` containing the status code.
        ///   - data: Optional response data.
        case endpointError(HTTPURLResponse, Data?)
        
        /// Represents a custom network error with an optional error code and description.
        /// - Parameters:
        ///   - errorCode: An optional error code.
        ///   - errorDescription: An optional error message.
        case custom(errorCode: Int?, errorDescription: String?)
    }
}

// MARK: - Extend NSError to Conform to DMError

/// Extends `NSError` to conform to `DMError` and `LocalizedError`.
extension NSError: @retroactive LocalizedError {
    
    /// Provides a localized description for the error.
    /// - Returns: A string describing the error in a user-friendly manner.
    public var errorDescription: String? {
        return self.localizedDescription
    }
}
extension NSError: DMError { }

// MARK: - Localized Error Text

/// Conformance to `LocalizedError` for `DMAppError.NetworkError`.
extension DMAppError.NetworkError: LocalizedError {
    
    /// Provides a localized description for the network error.
    /// - Returns: A string describing the error in a user-friendly manner.
    public var errorDescription: String? {
        switch self {
        case .inaccessible:
            return "The network is inaccessible. Please check your internet connection."
        case .urlError(let urlError):
            return urlError.localizedDescription
        case .generalError(let error):
            return error.localizedDescription
        case .noResponse:
            return "No response was received from the server."
        case .invalidResponseType(let response):
            return "Invalid response type received: \(response.debugDescription)"
        case .noResponseData(let httpResponse):
            return "The server returned an empty response for status code \(httpResponse.statusCode)."
        case .endpointError(let httpResponse, _):
            return "Endpoint error with status code \(httpResponse.statusCode)."
        case .custom(_, let errorDescription):
            return errorDescription ?? "A custom network error occurred."
        }
    }
}

/// Conformance to `LocalizedError` for `DMAppError.ResourceError`.
extension DMAppError.ResourceError: LocalizedError {
    
    /// Provides a localized description for the resource error.
    /// - Returns: A string describing the error in a user-friendly manner.
    public var errorDescription: String? {
        switch self {
        case .notAvailable:
            return "The requested resource is not available."
        case .error(let underlyingError):
            return underlyingError.localizedDescription
        }
    }
}
