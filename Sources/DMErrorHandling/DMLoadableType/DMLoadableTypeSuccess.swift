//
//  DMErrorHandling
//
//  Created by Mykola Dementiev
//

/// A protocol that defines a type capable of representing a successful result in a loading operation.
/// Conforming types must also conform to `CustomStringConvertible`, ensuring they provide a
/// textual representation via the `description` property.
///
/// This protocol is typically used to represent successful outcomes in operations where
/// the result can be described as a string (e.g., success messages, status updates, etc.).
public protocol DMLoadableTypeSuccess: CustomStringConvertible { }

/// Extends the `String` type to conform to the `DMLoadableTypeSuccess` protocol.
/// By doing so, any `String` instance can now be used as a type that represents
/// a successful result in a loading operation.
///
/// Example:
/// ```swift
/// let successMessage: DMLoadableTypeSuccess = "Operation completed successfully"
/// print(successMessage.description) // Output: "Operation completed successfully"
/// ```
extension String: DMLoadableTypeSuccess { }
