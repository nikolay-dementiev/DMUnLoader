//
//  DMGlobalLoadingStateManager.swift
//  DMErrorHandling
//
//  Created by Nikolay Dementiev on 01.02.2025.
//

import Combine

public final class GlobalLoadingStateManager: ObservableObject, Observable {
    @Published internal(set) public var loadableState: DMLoadableType = .none
    
    internal var isLoading: Bool {
        return loadableState == .loading
    }
    
    private var loadingManagerCancellables: [UUID: AnyCancellable] = [:]

    @MainActor
    internal func subscribeToLoadingManagers(_ loadingManagers: DMLoadingManager...) {
        // Subscribes to each of DMLoadingManager's object
        loadingManagers.forEach { manager in
            let cancellable = manager.loadableStatePublisher
                .sink { [weak self] state in
                    self?.loadableState = state
                }
            loadingManagerCancellables[manager.id] = cancellable
        }
    }
    
    internal func unsubscribeFromLoadingManager(_ manager: DMLoadingManager) {
        loadingManagerCancellables[manager.id] = nil
    }
}
