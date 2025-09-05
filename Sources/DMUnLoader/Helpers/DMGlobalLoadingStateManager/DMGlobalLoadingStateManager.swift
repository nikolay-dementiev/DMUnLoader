//
//  DMUnLoader
//
//  Created by Mykola Dementiev
//

import Combine
import Foundation

/// A concrete implementation of `GlobalLoadingStateManagerInternalProtocol` that manages
/// the global loadable state by subscribing to multiple loading managers.
///
/// This class aggregates the loadable states of individual loading managers and exposes
/// a unified global state (`loadableState`) to the user interface.
public final class GlobalLoadingStateManager: GlobalLoadingStateManagerInternalProtocol {
    
    /// A unique identifier for the global loading state manager.
    public let id: UUID = UUID()
    
    /// The current global loadable state, representing the combined state of all subscribed loading managers.
    /// - Note: This property is thread-safe and emits changes via Combine's `@Published`.
    @Published internal(set) public var loadableState: DMLoadableType = .none
    
    /// Indicates whether any of the subscribed loading managers are currently in a loading state.
    /// - Returns: `true` if the global state is `.loading`; otherwise, `false`.
    /// - Example:
    ///   ```swift
    ///   if globalLoadingStateManager.isLoading {
    ///       print("At least one loading manager is active")
    ///   } else {
    ///       print("No loading managers are active")
    ///   }
    ///   ```
    internal var isLoading: Bool {
        return loadableState == .loading
    }
    
    /// A dictionary mapping loading manager IDs to their respective cancellable subscriptions.
    private var loadingManagerCancellables: [UUID: AnyCancellable] = [:]
    
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
    internal func subscribeToLoadingManagers<LLM: DMLoadingManagerInteralProtocol>(_ loadingManagers: LLM...) {
        // Subscribes to each of the loading managers' state publishers
        loadingManagers.forEach { manager in
            let cancellable = manager.loadableStatePublisher
                .sink { [weak self] state in
                    self?.loadableState = state
                }
            loadingManagerCancellables[manager.id] = cancellable
        }
    }
    
    /// Unsubscribes the global loading state manager from a specific loading manager.
    /// - Parameter manager: The loading manager to unsubscribe from.
    /// - Note: This method must be called on the main actor.
    /// - Example:
    ///   ```swift
    ///   let manager = DMLoadingManager(state: .none, settings: DMLoadingManagerDefaultSettings())
    ///   globalLoadingStateManager.unsubscribeFromLoadingManager(manager)
    ///   ```
    @MainActor
    internal func unsubscribeFromLoadingManager<LLM: DMLoadingManagerInteralProtocol>(_ manager: LLM) {
        loadingManagerCancellables[manager.id] = nil
    }
}
