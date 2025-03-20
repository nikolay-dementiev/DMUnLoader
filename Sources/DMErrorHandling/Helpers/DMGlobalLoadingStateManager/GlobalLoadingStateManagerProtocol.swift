//
//  DMErrorHandling
//
//  Created by Mykola Dementiev
//

import Foundation

/// A protocol defining the public interface for a global loading state manager.
/// Conforming types must also conform to `ObservableObject` and `Observable`.
///
/// This protocol is used to manage and expose the global loadable state (e.g., `.none`, `.loading`, `.success`, `.failure`)
/// across multiple loading managers in a user interface.
public protocol GlobalLoadingStateManagerProtocol: ObservableObject, Observable {
    
    /// The current global loadable state, representing the combined state of all subscribed loading managers.
    /// - Example:
    ///   ```swift
    ///   let state = globalLoadingStateManager.loadableState
    ///   switch state {
    ///   case .none:
    ///       print("No loading state")
    ///   case .loading:
    ///       print("Loading in progress")
    ///   case .success(let message):
    ///       print("Success: \(message)")
    ///   case .failure(let error, _):
    ///       print("Failure: \(error.localizedDescription)")
    ///   }
    ///   ```
    var loadableState: DMLoadableType { get }
}

/// An internal protocol extending `GlobalLoadingStateManagerProtocol` to include additional functionality
/// required for managing subscriptions to individual loading managers.
///
/// This protocol is intended for use within the module and should not be exposed publicly.
internal protocol GlobalLoadingStateManagerInternalProtocol: GlobalLoadingStateManagerProtocol {
    
    /// A unique identifier for the global loading state manager.
    var id: UUID { get }
    
    /// Indicates whether any of the subscribed loading managers are currently in a loading state.
    /// - Returns: `true` if at least one loading manager is in the `.loading` state; otherwise, `false`.
    /// - Example:
    ///   ```swift
    ///   if globalLoadingStateManager.isLoading {
    ///       print("At least one loading manager is active")
    ///   } else {
    ///       print("No loading managers are active")
    ///   }
    ///   ```
    var isLoading: Bool { get }
    
    /// Subscribes the global loading state manager to one or more loading managers.
    /// - Parameter loadingManagers: A variadic list of loading managers conforming to `DMLoadingManagerInteralProtocol`.
    /// - Note: This method must be called on the main actor.
    /// - Example:
    ///   ```swift
    ///   let manager1 = DMLoadingManager(state: .none, settings: DMLoadingManagerDefaultSettings())
    ///   let manager2 = DMLoadingManager(state: .none, settings: DMLoadingManagerDefaultSettings())
    ///   globalLoadingStateManager.subscribeToLoadingManagers(manager1, manager2)
    ///   ```
    @MainActor
    func subscribeToLoadingManagers<LLM: DMLoadingManagerInteralProtocol>(_ loadingManagers: LLM...)
    
    /// Unsubscribes the global loading state manager from a specific loading manager.
    /// - Parameter manager: The loading manager to unsubscribe from.
    /// - Note: This method must be called on the main actor.
    /// - Example:
    ///   ```swift
    ///   let manager = DMLoadingManager(state: .none, settings: DMLoadingManagerDefaultSettings())
    ///   globalLoadingStateManager.unsubscribeFromLoadingManager(manager)
    ///   ```
    @MainActor
    func unsubscribeFromLoadingManager<LLM: DMLoadingManagerInteralProtocol>(_ manager: LLM)
}
