//
//  DMGlobalLoadingStateManager.swift
//  DMErrorHandling
//
//  Created by Nikolay Dementiev on 01.02.2025.
//

import Combine
import Foundation

public final class GlobalLoadingStateManager: GlobalLoadingStateManagerInternalProtocol {
    let id: UUID = UUID()
    @Published internal(set) public var loadableState: DMLoadableType = .none
    
    internal var isLoading: Bool {
        return loadableState == .loading
    }
    
    private var loadingManagerCancellables: [UUID: AnyCancellable] = [:]

    @MainActor
    internal func subscribeToLoadingManagers<LLM: DMLoadingManagerInteralProtocol>(_ loadingManagers: LLM...) {
        // Subscribes to each of DMLoadingManager's object
        loadingManagers.forEach { manager in
            let cancellable = manager.loadableStatePublisher
                .sink { [weak self] state in
                    self?.loadableState = state
                }
            loadingManagerCancellables[manager.id] = cancellable
        }
    }
    
    @MainActor
    internal func unsubscribeFromLoadingManager<LLM: DMLoadingManagerInteralProtocol>(_ manager: LLM) {
        loadingManagerCancellables[manager.id] = nil
    }
}
