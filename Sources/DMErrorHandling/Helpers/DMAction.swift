//
//  File.swift
//  DMErrorHandling
//
//  Created by Nikolay Dementiev on 10.02.2025.
//

import Foundation

// Composition of Action

public protocol DMActionResultValueProtocol: Copyable {
    var attemptCount: UInt? { get }
}

public protocol DMAction {
    typealias ResultType = Result<Copyable, Error>
    typealias ActionType = (@escaping (ResultType) -> Void) -> Void
    
    var currentAttempt: UInt { get }
    var id: UUID { get }
    var action: ActionType { get }
    
    var simpleAction: () -> Void { get }
}

public struct DMButtonAction: DMAction {
    private enum Settings {
        static let defaultAttemptCount: UInt = 0
    }
    
    public let currentAttempt: UInt
    public let id: UUID = UUID()
    
    public let action: ActionType
    
    internal init(currentAttempt: UInt,
                  action: @escaping ActionType) {
        self.currentAttempt = currentAttempt
        self.action = { completion in
            action { result in
                let finalResult = Self.mapResultWithAttempt(result, attempt: currentAttempt)
                completion(finalResult)
            }
        }
    }
    
    public init(_ action: @escaping ActionType) {
        self.init(currentAttempt: Settings.defaultAttemptCount,
                  action: action)
    }
    
    public init(_ simpleAction: @escaping () -> Void) {
        self.init({ completion in
            simpleAction()
            completion(.success(DMActionResultValue(value: PlaceholderCopyable(),
                                                    attemptCount: Settings.defaultAttemptCount)))
        })
    }
}

public struct DMActionWithFallback: DMAction {
    public let currentAttempt: UInt
    public let id: UUID = UUID()
    public let action: ActionType
    
    // Initialize with primary and fallback actions
    public init(currentAttempt: UInt,
                _ primaryAction: @escaping ActionType,
                _ fallbackAction: @escaping ActionType) {
        self.currentAttempt = currentAttempt
        self.action = { [fallbackAction] completion in
            primaryAction { result in
                switch result {
                case .success:
                    let finalResult = Self.mapResultWithAttempt(result, attempt: currentAttempt)
                    completion(finalResult)
                case .failure:
                    let fallbackActionWithIncrement = DMButtonAction(currentAttempt: currentAttempt + 1,
                                                                     action: fallbackAction)
                    fallbackActionWithIncrement.action(completion)
                }
            }
        }
    }
}

public extension DMAction {
    var simpleAction: () -> Void {
        {
            self.action { _ in }
        }
    }
    
    func fallbackTo(_ fallback: DMAction) -> DMActionWithFallback {
        DMActionWithFallback(currentAttempt: self.currentAttempt + 1, self.action, fallback.action)
    }
    
    func retry(_ retryCount: UInt) -> DMAction {
        var currentAction: DMAction = self
        
        (0..<retryCount).forEach { _ in
            currentAction = currentAction.fallbackTo(self)
        }
        
        return currentAction
    }
    
    func callAsFunction(completion: @escaping (ResultType) -> Void) {
        self.action { result in
            let finalResult = Self.mapResultWithAttempt(result, attempt: currentAttempt)
            completion(finalResult)
        }
    }
}

public extension DMActionResultValueProtocol {
    var attemptCount: UInt? { nil }
}

public extension Result where Success: Copyable, Failure == Error {
    func unwrapValue() -> DMAction.ResultType {
        self.map(unwrapNestedResult)
    }
    
    internal var attemptCount: UInt? {
        (try? self.get() as? DMActionResultValue)?.attemptCount
    }
    
    private func unwrapNestedResult(_ value: Copyable) -> Copyable {
        var unwrappedValue: Copyable = value
        
        // Recursively unwrap nested DMActionResultValue
        while let nestedValue = (unwrappedValue as? DMActionResultValue)?.value {
            unwrappedValue = nestedValue
        }
        
        return unwrappedValue
    }
}

private extension DMAction {
    static func mapResultWithAttempt(_ result: ResultType, attempt: UInt) -> ResultType {
        result.map {
            let valueWithoutWrapper = unwrapNestedResult($0)
            return DMActionResultValue(value: valueWithoutWrapper, attemptCount: attempt) as DMActionResultValueProtocol
        }
    }
    
    static func unwrapNestedResult(_ value: Copyable) -> Copyable {
        var unwrappedValue: Copyable = value
        
        // Recursively unwrap nested DMActionResultValue
        while let nestedValue = (unwrappedValue as? DMActionResultValue)?.value {
            unwrappedValue = nestedValue
        }
        
        return unwrappedValue
    }
}

// MARK: Helpers

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
