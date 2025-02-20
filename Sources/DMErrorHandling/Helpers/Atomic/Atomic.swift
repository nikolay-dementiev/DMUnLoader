//
//  DMErrorHandling
//
//  Created by Mykola Dementiev
//

import Foundation

@propertyWrapper
internal final class Atomic<ValueType: Sendable>: @unchecked Sendable {
    private var _property: ValueType
    private let wQueue: DispatchQueue = {
        let name = "AtomicProperty" + String(Int.random(in: 0...100000)) + String(describing: ValueType.self)
        return DispatchQueue(label: name,
                             qos: .userInitiated,
                             attributes: .concurrent)
    }()
    
    internal var projectedValue: Atomic<ValueType> {
        // swiftlint:disable:next implicit_getter
        get { self }
    }
    
    internal var wrappedValue: ValueType {
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
    
    internal init(_ wrappedValue: ValueType) {
        self._property = wrappedValue
    }
    
    internal func callAsFunction() -> ValueType {
        wrappedValue
    }
    
    // perform an atomic operation on the atomic property
    // the operation will not run if the property is nil.
    public func mutate(mutation: ((_ prop: inout ValueType) -> Void)) {
        wQueue.sync(flags: .barrier) { [weak self] in
            if var prop = self?._property {
                mutation(&prop)
                self?._property = prop
            }
        }
    }
}
