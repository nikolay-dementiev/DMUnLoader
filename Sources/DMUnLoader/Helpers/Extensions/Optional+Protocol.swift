//
//  DMUnLoader
//
//  Created by Mykola Dementiev
//

/// Checks for and unwraps the value of an optional.
extension Optional {
    
    /// Checks whether the optional contains a value (`.some`) or is `nil` (`.none`).
    public func isSomeValue() -> Bool {
        switch self {
        case .none:
            return false
        case .some:
            return true
        }
    }
    
    /// Unwraps the optional value safely, throwing an error if the value is `nil`.
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
