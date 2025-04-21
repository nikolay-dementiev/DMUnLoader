//
//  DMErrorHandling
//
//  Created by Mykola Dementiev
//

import Combine
import Foundation

/// A protocol defining the interface for a top-level view controller that can handle loading state changes.
/// Conforming types must implement the `handleLoadingStateChange` method and manage a set of cancellables for subscriptions.
public protocol DMViewControllerTopLevel: AnyObject {
    
    /// Handles changes in the loading state.
    /// - Parameter state: The new loading state to handle.
    func handleLoadingStateChange(_ state: DMLoadableType)
    
    /// A set of cancellable subscriptions used to manage Combine publishers.
    var cancellableTopLevelView: Set<AnyCancellable> { get set }
}

/// An extension on `DMViewControllerTopLevel` to provide shared subscription management.
internal extension DMViewControllerTopLevel {
    
    /// A weakly-held collection of subscribed objects to prevent duplicate subscriptions.
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

/// A public extension on `DMViewControllerTopLevel` to provide default implementations and utility methods.
public extension DMViewControllerTopLevel {
    
    /// A set of cancellable subscriptions used to manage Combine publishers.
    /// - Note: This property is backed by a shared instance of `DMViewControllerTopLevelSubscriptionHolder`.
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
    
    /// Subscribes to loading state changes from a `GlobalLoadingStateManager`.
    /// - Parameter manager: The global loading state manager to subscribe to.
    /// - Behavior:
    ///   - Ensures that the object is not already subscribed before adding a new subscription.
    ///   - Uses Combine to observe changes in the `loadableState` property of the manager.
    ///   - Calls `handleLoadingStateChange` whenever the state changes.
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

/// A private struct used to hold shared subscription-related data for `DMViewControllerTopLevel` conforming objects.
private struct DMViewControllerTopLevelSubscriptionHolder {
    
    /// A shared instance of `DMViewControllerTopLevelSubscriptionHolder`.
    nonisolated(unsafe) static var shared = Self()
    
    /// A set of cancellable subscriptions used to manage Combine publishers.
    var cancellableTopLevelView: Set<AnyCancellable> = []
    
    /// A weakly-held collection of subscribed objects to prevent duplicate subscriptions.
    var subscribedObjects = NSHashTable<AnyObject>.weakObjects()
}
