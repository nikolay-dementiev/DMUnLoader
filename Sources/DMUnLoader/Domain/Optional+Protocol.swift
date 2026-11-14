//
//  DMUnLoader
//
//  Created by Mykola Dementiev
//

/// Checks for and unwraps the value of an optional.
///
/// Retired: both members are removed in 2.0.0.
extension Optional {
    
    /// Checks whether the optional contains a value (`.some`) or is `nil` (`.none`).
    ///
    /// Retired: compare with `nil`, or use `if let` or `??`. Removed in 2.0.0.
    public func isSomeValue() -> Bool {
        switch self {
        case .none:
            return false
        case .some:
            return true
        }
    }
    
    /// Unwraps the optional value safely, throwing an error if the value is `nil`.
    ///
    /// Retired: unwrap with `guard let` and throw an error of your own. This method returns `Any`,
    /// so it erases the type, and the error it throws is not public. Removed in 2.0.0.
    public func unwrapValue() throws -> Any {
        switch self {
        case .none:
            throw OptionalError.unwrappingNil
        case .some(let unwrapped):
            return unwrapped
        }
    }
}

/// An error type representing issues related to unwrapping optional values.
enum OptionalError: Error {
    
    /// Indicates that an attempt was made to unwrap a `nil` optional value.
    case unwrappingNil
}
