//
//  DMViewControllerTopLevel.swift
//  DMErrorHandling
//
//  Created by Nikolay Dementiev on 06.02.2025.
//

import Combine

public protocol DMViewControllerTopLevel: AnyObject {
    func handleLoadingStateChange(_ state: DMLoadableType)
    var cancellableTopLevelView: Set<AnyCancellable> { get set }
}

public extension DMViewControllerTopLevel {
    var cancellableTopLevelView: Set<AnyCancellable> {
        get {
            DMViewControllerTopLevelSubscriptionHolder.shared.cancellableTopLevelView
        }
        set(newValue) {
            let existingCancellables = DMViewControllerTopLevelSubscriptionHolder.shared.cancellableTopLevelView
            
            // Only add new elements that are not already in the global set
            let newCancellables = newValue.subtracting(existingCancellables)
            
            // Merge into the global storage
            DMViewControllerTopLevelSubscriptionHolder.shared.cancellableTopLevelView.formUnion(newCancellables)
        }
    }
    
    func subscribeToLoadingStateChange(from manager: GlobalLoadingStateManager) {
        manager.$loadableState
            .receive(on: DispatchQueue.main)
            .removeDuplicates()
            .sink { [weak self] state in
                self?.handleLoadingStateChange(state)
            }
            .store(in: &cancellableTopLevelView)
    }
}

fileprivate struct DMViewControllerTopLevelSubscriptionHolder {
    static var shared = Self()
    
    var cancellableTopLevelView: Set<AnyCancellable> = []
}
