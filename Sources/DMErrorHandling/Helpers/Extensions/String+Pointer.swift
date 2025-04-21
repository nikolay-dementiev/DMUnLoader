//
//  DMErrorHandling
//
//  Created by Mykola Dementiev
//

import Foundation

/// An extension on `String` to provide utility methods for working with object pointers.
internal extension String {
    
    /// Generates a string representation of the memory address of a given object.
    /// - Parameter object: The object whose memory address is to be represented as a string.
    ///                     If `nil`, the method returns `"nil"`.
    /// - Returns: A string representation of the object's memory address, or `"nil"` if the object is `nil`.
    /// - Note: This method uses `Unmanaged.passUnretained` to obtain the object's memory address.
    /// - Example:
    ///   ```swift
    ///   class MyClass {}
    ///   let instance = MyClass()
    ///
    ///   let pointerString = String.pointer(instance)
    ///   print(pointerString) // Output: "0x00007ff8b9c0d2f0" (example memory address)
    ///
    ///   let nilPointerString = String.pointer(nil)
    ///   print(nilPointerString) // Output: "nil"
    ///   ```
    static func pointer(_ object: AnyObject?) -> String {
        guard let object = object else {
            return "nil"
        }
        let opaque: UnsafeMutableRawPointer = Unmanaged.passUnretained(object).toOpaque()
        return String(describing: opaque)
    }
}
