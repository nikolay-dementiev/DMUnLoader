//
//  DMUnLoader
//
//  Created by Mykola Dementiev
//

// For more details on the functionality of this module, refer to:
// https://stackoverflow.com/a/39983813/6643923

import Foundation

/// An extension on `DispatchQueue` to provide thread-safe, one-time execution of code blocks.
/// This extension ensures that a block of code is executed only once, even in multithreaded environments.
extension DispatchQueue {
    
    /// A private static array used to track tokens for one-time execution.
    /// - Note: This property is marked as `nonisolated(unsafe)` to allow access across threads.
    nonisolated(unsafe) private static var _onceTracker = [String]()
    
    /// Resets the tracker array, clearing all previously tracked tokens.
    /// - Warning: Use this method with caution, as it will allow previously executed blocks to run again.
    /// - Example:
    ///   ```swift
    ///   DispatchQueue.resetTrackersSet()
    ///   ```
    static func resetTrackersSet() {
        _onceTracker.removeAll()
    }
    
    /// Executes a block of code only once for a given object, ensuring thread safety.
    /// - Parameters:
    ///   - object: The object associated with the block. If `nil`, the block is not tied to any specific object.
    ///   - file: The file name where the method is called (default: `#file`).
    ///   - function: The function name where the method is called (default: `#function`).
    ///   - line: The line number where the method is called (default: `#line`).
    ///   - position: Specifies whether the block should be tied to the current context or any context (default: `.current`).
    ///   - block: The block of code to execute.
    /// - Example:
    ///   ```swift
    ///   let myObject = NSObject()
    ///   DispatchQueue.once(forObject: myObject) {
    ///       print("This block will execute only once for myObject")
    ///   }
    ///   ```
    class func once(forObject object: AnyObject? = nil,
                    file: String = #file,
                    function: String = #function,
                    line: Int = #line,
                    position: ObjectPosition = .current,
                    block: () -> Void) {
        
        let objectsToProvide: [AnyObject]?
        if let object {
            objectsToProvide = [object]
        } else {
            objectsToProvide = nil
        }
        
        once(forObjects: objectsToProvide,
             file: file,
             function: function,
             line: line,
             position: position,
             block: block)
    }
    
    /// Executes a block of code only once for a given set of objects, ensuring thread safety.
    /// - Parameters:
    ///   - objects: An array of objects associated with the block. If `nil`, the block is not tied to any specific objects.
    ///   - file: The file name where the method is called (default: `#file`).
    ///   - function: The function name where the method is called (default: `#function`).
    ///   - line: The line number where the method is called (default: `#line`).
    ///   - position: Specifies whether the block should be tied to the current context or any context (default: `.current`).
    ///   - block: The block of code to execute.
    /// - Example:
    ///   ```swift
    ///   let object1 = NSObject()
    ///   let object2 = NSObject()
    ///   DispatchQueue.once(forObjects: [object1, object2]) {
    ///       print("This block will execute only once for the combination of object1 and object2")
    ///   }
    ///   ```
    class func once(forObjects objects: [AnyObject]?,
                    file: String = #file,
                    function: String = #function,
                    line: Int = #line,
                    position: ObjectPosition = .current,
                    block: () -> Void) {
        let objectsTokenString: String = (
            objects?
                .map({ String.pointer($0) })
                .joined(separator: ";")
        ).getValueOrNullSting()
        
        let token: String
        switch position {
        case .any:
            token = "\(objectsTokenString)"
        case .current:
            token = "\(objectsTokenString)\(file):\(function):\(line)"
        }
       
        once(token: token, block: block)
    }
    
    /**
     Executes a block of code, associated with a unique token, only once. The code is thread-safe and will
     only execute the block once, even in the presence of multithreaded calls.
     
     - Parameter token: A unique reverse DNS style name such as `com.vectorform.<name>` or a GUID.
     - Parameter block: The block of code to execute.
     - Example:
     ```swift
     DispatchQueue.once(token: "com.example.uniqueToken") {
         print("This block will execute only once for the given token")
     }
     ```
     */
    class func once(token: String,
                    block: () -> Void) {
        objc_sync_enter(self)
        defer { objc_sync_exit(self) }
        
        guard !_onceTracker.contains(token) else {
            return
        }
        
        _onceTracker.append(token)
        block()
    }
    
    /// Specifies the context in which the one-time execution should occur.
    enum ObjectPosition {
        /// The block is tied to the current file, function, and line context.
        case current
        
        /// The block is not tied to any specific context and can execute in any context.
        case any
    }
}
