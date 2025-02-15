//
//  File.swift
//  DMErrorHandling
//
//  Created by Nikolay Dementiev on 10.02.2025.
//

import Foundation

// Composition of Action

public protocol DMAction {
    typealias ResultType = Result<Copyable, Error>
    typealias ActionType = (@escaping (ResultType) -> Void) -> Void
    
    var currentAttempt: UInt { get }
    var id: UUID { get }
    var action: ActionType { get }
    
    var simpleAction: () -> Void { get }
}

public struct DMButtonAction: DMAction {
    public let currentAttempt: UInt
    public let id: UUID = UUID()
    
    public let action: ActionType
    
    internal init(currentAttempt: UInt,
                  action: @escaping ActionType) {
        self.currentAttempt = currentAttempt
        self.action = action
    }
    
    public init(_ action: @escaping ActionType) {
        self.init(currentAttempt: 0,
                  action: action)
    }
    
    public init(_ simpleAction: @escaping () -> Void) {
        self.init({ completion in
            simpleAction()
            completion(.success(PlaceholderCopyable()))
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
                    completion(result)
                case .failure:
                    print("Execution failed. Trying once again; attempt #: `\(currentAttempt)`")
                    fallbackAction(completion)
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
}

public struct PlaceholderCopyable: Copyable {
    public init() {
        
    }
}
