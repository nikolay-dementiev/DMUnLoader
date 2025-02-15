//
//  File.swift
//  DMErrorHandling
//
//  Created by Nikolay Dementiev on 13.01.2025.
//

import Foundation

public protocol DMError: Error, LocalizedError {
}

public enum DMAppError: DMError {
    case resourceError(type: ResourceError)
    case network(type: NetworkError)
//    case invalidInput
    case custom(_ errorDescription: String?)
    
    case generalError(DMError)
}

public extension DMAppError {
    enum ResourceError: DMError {
        case notAvailable
        case error(Error)
    }
}

/// Localized error
extension DMAppError: LocalizedError {
    public var errorDescription: String? {
        switch self {
        case .resourceError(let type):
            return type.localizedDescription
        case .network(let type):
            return type.localizedDescription
        case .custom(let errorDescription):
            return errorDescription
//        case .decoding(let type): return type.localizedDescription
//        case .activity(let type): return type.localizedDescription
//        case .dfu(let type): return type.localizedDescription
//        case .invalidInput:
            
        case .generalError(let error): return String(describing: error.localizedDescription)
        }
    }
}

// MARK: - Connection Errors
/// Connection Errors Enums
/// It pass-through any URLErrors that happen and add its own
extension DMAppError {
    public enum NetworkError: DMError {
        ///    When network conditions are so bad that after `maxRetries` the request did not succeed.
        case inaccessible

        ///    `URLSession` errors are passed-through, handle as appropriate.
        case urlError(URLError)

//        ///    URLSession returned an `Error` object which is not `URLError`
//        case generalError(Swift.Error)

        ///    When no `URLResponse` is returned but also no `URLError` or any other `Error` instance.
        case noResponse

        ///    When `URLResponse` is not `HTTPURLResponse`.
        case invalidResponseType(URLResponse)

        ///    Status code is in `200...299` range, but response body is empty. This can be both
        ///    valid and invalid, depending on HTTP method and/or specific behavior of the service being called.
        case noResponseData(HTTPURLResponse)

        ///    Status code is `400` or higher thus return the entire `HTTPURLResponse` and `Data`
        ///    so caller can figure out what happened.
        case endpointError(HTTPURLResponse, Data?)
        
        /// custom error
        case custom(errorCode: Int?, errorDescription: String?)
    }
}
