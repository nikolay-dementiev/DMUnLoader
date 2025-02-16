//
//  DMActionResultValue.swift
//  DMErrorHandling
//
//  Created by Nikolay Dementiev on 16.02.2025.
//

public struct DMActionResultValue: DMActionResultValueProtocol {
    public let attemptCount: UInt?
    public let value: Copyable
    
    public init(value: Copyable,
                attemptCount: UInt? = nil) {
        self.value = value
        self.attemptCount = attemptCount
    }
}

public struct PlaceholderCopyable: Copyable {
    public init() { }
}
