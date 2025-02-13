//
//  Atomic.swift
//  DMErrorHandling
//
//  Created by Nikolay Dementiev on 24.01.2025.
//

import Foundation

@propertyWrapper
internal final class Atomic<ValueType> {
    private var _property: ValueType
    private let wQueue: DispatchQueue = {
        let name = "AtomicProperty" + String(Int.random(in: 0...100000)) + String(describing: ValueType.self)
        return DispatchQueue(label: name,
                             qos: .userInitiated,
                             attributes: .concurrent)
    }()
    
    public var projectedValue: Atomic<ValueType> {
        // swiftlint:disable:next implicit_getter
        get { self }
    }
    
    public var wrappedValue: ValueType {
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
    
    public init(_ wrappedValue: ValueType) {
        self._property = wrappedValue
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
