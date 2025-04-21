//
//  DMErrorHandling
//
//  Created by Mykola Dementiev
//

/// An enumeration representing the possible states of a loadable operation.
/// Conforms to `Hashable` and `RawRepresentable` for easy comparison and serialization.
public enum DMLoadableType: Hashable, RawRepresentable {
    
    /// The raw value type for this enum, represented as a `String`.
    public typealias RawValue = String
    
    /// Indicates that the operation is currently in progress.
    case loading
    
    /// Indicates that the operation has failed, with an associated error and an optional retry action.
    /// - Parameters:
    ///   - error: The error that occurred during the operation.
    ///   - onRetry: An optional action to retry the operation.
    case failure(error: Error, onRetry: DMAction? = nil)
    
    /// Indicates that the operation has succeeded, with an associated success message or object.
    /// - Parameter message: The success message or object associated with the operation.
    case success(DMLoadableTypeSuccess)
    
    /// Indicates that no operation is currently active.
    case none
    
    /// The raw value representation of the `DMLoadableType` instance.
    /// - Returns: A string describing the current state.
    /// - Example:
    ///   ```swift
    ///   let state: DMLoadableType = .loading
    ///   print(state.rawValue) // Output: "Loading"
    ///
    ///   let errorState = DMLoadableType.failure(error: NSError(domain: "Example", code: 404), onRetry: nil)
    ///   print(errorState.rawValue) // Output: "Error: `Error Domain=Example Code=404 \"The operation couldn’t be completed.\"`"
    ///   ```
    public var rawValue: RawValue {
        let rawValueForReturn: RawValue
        switch self {
        case .loading:
            rawValueForReturn = "Loading"
        case .failure(let error, _):
            rawValueForReturn = "Error: `\(error)`"
        case .success(let message):
            rawValueForReturn = "Success: `\(message.description)`"
        case .none:
            rawValueForReturn = "None"
        }
        
        return rawValueForReturn
    }
    
    /// Initializes a `DMLoadableType` instance from a raw value.
    /// - Parameter rawValue: The raw value to initialize from.
    /// - Note: This initializer always returns `nil` because deserialization from raw values is not supported.
    /// - Example:
    ///   ```swift
    ///   let state = DMLoadableType(rawValue: "Loading")
    ///   print(state) // Output: nil
    ///   ```
    public init?(rawValue: RawValue) {
        nil
    }
    
    /// Compares two `DMLoadableType` instances for equality.
    /// - Parameters:
    ///   - lhs: The left-hand side instance.
    ///   - rhs: The right-hand side instance.
    /// - Returns: `true` if both instances have the same hash value; otherwise, `false`.
    public static func == (lhs: DMLoadableType,
                           rhs: DMLoadableType) -> Bool {
        lhs.hashValue == rhs.hashValue
    }
    
    /// Hashes the `DMLoadableType` instance into the provided hasher.
    /// - Parameter hasher: The hasher to use for combining the hash value.
    public func hash(into hasher: inout Hasher) {
        hasher.combine(rawValue)
    }
}
