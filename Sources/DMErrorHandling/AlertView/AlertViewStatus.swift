//
//  File.swift
//  DMErrorHandling
//
//  Created by Nikolay Dementiev on 19.01.2025.
//

import SwiftUI

public enum AlertViewStatus: RawRepresentable {
    
    public typealias RawValue = AlertViewStatusRawValue
    
    case loadable(LoadableType)
    case unknown
    
    public var rawValue: RawValue {
        let rawValueForReturn: RawValue
        switch self {
        case .unknown:
            rawValueForReturn = .unknown
        case .loadable(.loading):
            rawValueForReturn = .loadaingInProcess
        case .loadable(.success):
            rawValueForReturn = .loadaingSuccessed
        case .loadable(.failure):
            rawValueForReturn = .loadaingFailured
        }
        
        return rawValueForReturn
    }
    
    public init?(rawValue: RawValue) {
        nil
    }
    
    public enum AlertViewStatusRawValue : Sendable {
        case unknown,
             loadaingInProcess,
             loadaingSuccessed,
             loadaingFailured
    }
}

extension AlertViewStatus: Hashable {
    public static func == (lhs: AlertViewStatus,
                           rhs: AlertViewStatus) -> Bool {
        lhs.hashValue == rhs.hashValue
    }
    
    public func hash(into hasher: inout Hasher) {
        hasher.combine(rawValue)
    }
}
