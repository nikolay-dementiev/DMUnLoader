//
//  DMErrorHandling
//
//  Created by Mykola Dementiev
//

import Combine
import Foundation

public protocol DMViewControllerTopLevel: AnyObject {
    func handleLoadingStateChange(_ state: DMLoadableType)
    var cancellableTopLevelView: Set<AnyCancellable> { get set }
}

internal extension DMViewControllerTopLevel {
    var subscribedObjects: NSHashTable<AnyObject> {
        get {
            DMViewControllerTopLevelSubscriptionHolder
                .shared
                .subscribedObjects
        }
        set {
            DMViewControllerTopLevelSubscriptionHolder
                .shared
                .subscribedObjects = newValue
        }
    }
}

public extension DMViewControllerTopLevel {
    var cancellableTopLevelView: Set<AnyCancellable> {
        get {
            DMViewControllerTopLevelSubscriptionHolder
                .shared
                .cancellableTopLevelView
        }
        set(newValue) {
            DMViewControllerTopLevelSubscriptionHolder
                .shared
                .cancellableTopLevelView = newValue
        }
    }
    
    func subscribeToLoadingStateChange(from manager: GlobalLoadingStateManager) {
        guard !subscribedObjects.contains(self) else {
            return
        }
        
        manager.$loadableState
            .receive(on: DispatchQueue.main)
            .removeDuplicates()
            .sink { [weak self] state in
                self?.handleLoadingStateChange(state)
            }
            .store(in: &cancellableTopLevelView)
        
        subscribedObjects.add(self)
    }
}

private struct DMViewControllerTopLevelSubscriptionHolder {
    nonisolated(unsafe) static var shared = Self()
    
    var cancellableTopLevelView: Set<AnyCancellable> = []
    var subscribedObjects = NSHashTable<AnyObject>.weakObjects()
}
