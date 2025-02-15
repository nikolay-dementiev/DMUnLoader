//
//  Optional+Protocol.swift
//  DMErrorHandling
//
//  Created by Nikolay Dementiev on 03.02.2025.
//

import Foundation

internal protocol OptionalProtocol {
    func isSomeValue() -> Bool
    func unwrapValue() -> Any
}

extension Optional: OptionalProtocol {
    func isSomeValue() -> Bool {
        switch self {
        case .none:
            return false
        case .some:
            return true
        }
    }

    func unwrapValue() -> Any {
        switch self {
        case .none:
            preconditionFailure("trying to unwrap nil")
        case .some(let unwrapped):
            return unwrapped
        }
    }
}

internal extension Optional where Wrapped: Collection {
    var isNilOrEmpty: Bool {
        return self?.isEmpty ?? true
    }
}

private func unwrapUsingProtocol<ObjType>(_ any: ObjType) -> Any {
    guard let optional = any as? OptionalProtocol,
            optional.isSomeValue() else {
        return any
    }
    return unwrapUsingProtocol(optional.unwrapValue())
}

internal extension Optional where Wrapped == String {
    static let nullEvent: String = NSString.nullEvent
    
    func getValueOrNullSting() -> Wrapped {
        guard self.isSomeValue(),
                let unwrappedValue = unwrapUsingProtocol(self) as? Wrapped else {
            return Self.nullEvent
        }
        
        return unwrappedValue
    }
    
    func getValueOrNullSting() -> Optional {
        guard self.isSomeValue() else {
            return Self.nullEvent
        }
        
        return self
    }
}

@objc
fileprivate extension NSString {
    static let nullEvent: String = "<null>"
}
