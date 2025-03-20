//
//  DMErrorHandling
//
//  Created by Mykola Dementiev
//

import Foundation

/// A protocol defining methods to check and unwrap optional values in a type-safe manner.
internal protocol OptionalProtocol {
    
    /// Checks whether the optional contains a value (`.some`) or is `nil` (`.none`).
    /// - Returns: `true` if the optional contains a value; otherwise, `false`.
    /// - Example:
    ///   ```swift
    ///   let optionalValue: Int? = 42
    ///   print(optionalValue.isSomeValue()) // Output: true
    ///
    ///   let nilValue: Int? = nil
    ///   print(nilValue.isSomeValue()) // Output: false
    ///   ```
    func isSomeValue() -> Bool
    
    /// Unwraps the optional value safely, throwing an error if the value is `nil`.
    /// - Returns: The unwrapped value as `Any`.
    /// - Throws: `OptionalError.unwrappingNil` if the optional is `nil`.
    /// - Example:
    ///   ```swift
    ///   let optionalValue: Int? = 42
    ///   do {
    ///       let unwrapped = try optionalValue.unwrapValue()
    ///       print(unwrapped) // Output: 42
    ///   } catch {
    ///       print("Failed to unwrap: \(error)")
    ///   }
    ///   ```
    func unwrapValue() throws -> Any
}

/// An extension on `Optional` to conform to `OptionalProtocol`.
extension Optional: OptionalProtocol {
    
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
    
    /// Recursively unwraps nested optional values using the `OptionalProtocol`.
    /// - Parameter any: The value to unwrap.
    /// - Returns: The fully unwrapped value, or the original value if unwrapping fails.
    private func unwrapUsingProtocol<ObjType>(_ any: ObjType) -> Any {
        guard let optional = any as? OptionalProtocol,
              optional.isSomeValue() else {
            return any
        }
        
        do {
            let unwrappedValue = try optional.unwrapValue()
            return unwrapUsingProtocol(unwrappedValue)
        } catch {
            return any
        }
    }
}

/// An extension on `Optional` where the wrapped type conforms to `Collection`.
internal extension Optional where Wrapped: Collection {
    
    /// Checks whether the optional is `nil` or contains an empty collection.
    /// - Returns: `true` if the optional is `nil` or the collection is empty; otherwise, `false`.
    /// - Example:
    ///   ```swift
    ///   let optionalArray: [Int]? = []
    ///   print(optionalArray.isNilOrEmpty) // Output: true
    ///
    ///   let nonEmptyArray: [Int]? = [1, 2, 3]
    ///   print(nonEmptyArray.isNilOrEmpty) // Output: false
    ///   ```
    var isNilOrEmpty: Bool {
        return self?.isEmpty ?? true
    }
}

/// An extension on `Optional` where the wrapped type is `String`.
internal extension Optional where Wrapped == String {
    
    /// A static constant representing a null event string (`"<null>"`).
    static let nullEvent: String = NSString.nullEvent
    
    /// Safely unwraps the optional string or returns the `nullEvent` string if unwrapping fails.
    /// - Returns: The unwrapped string if it exists; otherwise, `nullEvent`.
    /// - Example:
    ///   ```swift
    ///   let optionalString: String? = "Hello"
    ///   print(optionalString.getValueOrNullSting()) // Output: "Hello"
    ///
    ///   let nilString: String? = nil
    ///   print(nilString.getValueOrNullSting()) // Output: "<null>"
    ///   ```
    func getValueOrNullSting() -> Wrapped {
        guard self.isSomeValue(),
              let unwrappedValue = unwrapUsingProtocol(self) as? Wrapped else {
            return Self.nullEvent
        }
        
        return unwrappedValue
    }
    
    /// Safely unwraps the optional string or returns the `nullEvent` string as an optional.
    /// - Returns: The unwrapped string as an optional if it exists; otherwise, `nullEvent`.
    /// - Example:
    ///   ```swift
    ///   let optionalString: String? = "Hello"
    ///   print(optionalString.getValueOrNullSting()) // Output: Optional("Hello")
    ///
    ///   let nilString: String? = nil
    ///   print(nilString.getValueOrNullSting()) // Output: Optional("<null>")
    ///   ```
    func getValueOrNullSting() -> Optional {
        guard self.isSomeValue() else {
            return Self.nullEvent
        }
        
        return self
    }
}

/// An error type representing issues related to unwrapping optional values.
internal enum OptionalError: Error {
    
    /// Indicates that an attempt was made to unwrap a `nil` optional value.
    case unwrappingNil
}

/// A private extension on `NSString` to define a static constant for null events.
@objc
fileprivate extension NSString {
    
    /// A static constant representing a null event string (`"<null>"`).
    static let nullEvent: String = "<null>"
}
