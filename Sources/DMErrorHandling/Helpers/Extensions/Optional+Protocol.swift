//
//  Optional+Protocol.swift
//  DMErrorHandling
//
//  Created by Nikolay Dementiev on 03.02.2025.
//

import Foundation

internal protocol OptionalProtocol {
    func isSomeValue() -> Bool
    func unwrapValue() throws -> Any
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

    func unwrapValue() throws -> Any {
        switch self {
        case .none:
            throw OptionalError.unwrappingNil
        case .some(let unwrapped):
            return unwrapped
        }
    }
    
    private func unwrapUsingProtocol<ObjType>(_ any: ObjType) -> Any {
        guard let optional = any as? OptionalProtocol,
                optional.isSomeValue() else {
            return any
        }
        
        do {
            let unwrapedValue = try optional.unwrapValue()
            return unwrapUsingProtocol(unwrapedValue)
        } catch {
            return any
        }
    }
}

internal extension Optional where Wrapped: Collection {
    var isNilOrEmpty: Bool {
        return self?.isEmpty ?? true
    }
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

internal enum OptionalError: Error {
    case unwrappingNil
}

@objc
fileprivate extension NSString {
    static let nullEvent: String = "<null>"
}
