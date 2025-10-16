//
//  DMUnLoader
//
//  Created by Mykola Dementiev
//

import Foundation

/// A thread-safe property wrapper that ensures atomic access to a value of type `ValueType`.
/// This wrapper uses a concurrent `DispatchQueue` with barrier flags to synchronize read and write operations.
///
/// - Note: The `ValueType` must conform to `Sendable` to ensure thread safety.
@propertyWrapper
final class Atomic<ValueType: Sendable>: @unchecked Sendable {
    
    /// The underlying value wrapped by this property wrapper.
    private var _property: ValueType
    
    /// A private dispatch queue used to synchronize access to `_property`.
    /// - The queue is labeled uniquely to avoid conflicts and is configured as concurrent with a `.userInitiated` QoS.
    private let wQueue: DispatchQueue = {
        let name = "AtomicProperty" + String(Int.random(in: 0...100000)) + String(describing: ValueType.self)
        return DispatchQueue(label: name,
                             qos: .userInitiated,
                             attributes: .concurrent)
    }()
    
    /// Provides access to the `Atomic` instance itself (useful for chaining or additional operations).
    /// - Example:
    ///   ```swift
    ///   @Atomic var atomicValue: Int = 42
    ///   $atomicValue.mutate { $0 += 1 }
    ///   ```
    var projectedValue: Atomic<ValueType> {
        // swiftlint:disable:next implicit_getter
        get { self }
    }
    
    /// The wrapped value, accessed in a thread-safe manner.
    /// - Reads are performed synchronously on the dispatch queue.
    /// - Writes are performed asynchronously with a barrier to ensure exclusive access.
    /// - Example:
    ///   ```swift
    ///   var atomicValue = Atomic(10)
    ///   print(atomicValue.wrappedValue) // Output: 10
    ///   atomicValue.wrappedValue = 20
    ///   print(atomicValue.wrappedValue) // Output: 20
    ///   ```
    var wrappedValue: ValueType {
        get {
            wQueue.sync {
                return _property
            }
        }
        set {
            wQueue.async(flags: .barrier) { [weak self] in
                self?._property = newValue
            }
        }
    }
    
    /// Initializes the `Atomic` property wrapper with an initial value.
    /// - Parameter wrappedValue: The initial value to be wrapped.
    /// - Example:
    ///   ```swift
    ///   let atomicValue = Atomic(0)
    ///   print(atomicValue.wrappedValue) // Output: 0
    ///   ```
    init(_ wrappedValue: ValueType) {
        self._property = wrappedValue
    }
    
    /// Allows the `Atomic` instance to be called as a function, returning the current `wrappedValue`.
    /// - Returns: The current value of the wrapped property.
    /// - Example:
    ///   ```swift
    ///   let atomicValue = Atomic("Hello")
    ///   print(atomicValue()) // Output: "Hello"
    ///   ```
    func callAsFunction() -> ValueType {
        wrappedValue
    }
    
    /// Performs an atomic mutation operation on the wrapped value.
    /// - Parameter mutation: A closure that takes the wrapped value as an `inout` parameter and modifies it.
    /// - Note: The mutation is performed synchronously with a barrier to ensure thread safety.
    /// - Example:
    ///   ```swift
    ///   var atomicValue = Atomic([1, 2, 3])
    ///   atomicValue.mutate { $0.append(4) }
    ///   print(atomicValue.wrappedValue) // Output: [1, 2, 3, 4]
    ///   ```
    public func mutate(mutation: ((_ prop: inout ValueType) -> Void)) {
        wQueue.sync(flags: .barrier) { [weak self] in
            if var prop = self?._property {
                mutation(&prop)
                self?._property = prop
            }
        }
    }
}
