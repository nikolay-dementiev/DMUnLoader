//
//  MockGlobalLoadingStateManager.swift
//  DMErrorHandling
//
//  Created by Nikolay Dementiev on 13.02.2025.
//

import Foundation
import Combine
@testable import DMErrorHandling

final class MockGlobalLoadingStateManager: GlobalLoadingStateManagerInternalProtocol {
    let id: UUID
    @Published public var loadableState: DMLoadableType = .none
    
    var isLoading: Bool {
        return loadableState == .loading
    }
    
    private let subscribeToLoadingManagersBlock: (_ managerIds: [any DMLoadingManagerInteralProtocol]) -> Void
    private let unsubscribeFromLoadingManagerBlock: (_ managerId: any DMLoadingManagerInteralProtocol) -> Void
    
    init(id: UUID = UUID(),
         loadableState: DMLoadableType,
         subscribeToLoadingManagers: @escaping (_ loadingManagers: [any DMLoadingManagerInteralProtocol]) -> Void,
         unsubscribeFromLoadingManager: @escaping (_ manager: any DMLoadingManagerInteralProtocol) -> Void) {
        
        self.id = id
        self.loadableState = loadableState
        self.subscribeToLoadingManagersBlock = subscribeToLoadingManagers
        self.unsubscribeFromLoadingManagerBlock = unsubscribeFromLoadingManager
    }
    
    @MainActor
    func subscribeToLoadingManagers<LLM: DMLoadingManagerInteralProtocol>(_ loadingManagers: LLM...) {
        subscribeToLoadingManagersBlock(loadingManagers)
    }
    
    @MainActor
    func unsubscribeFromLoadingManager<LLM: DMLoadingManagerInteralProtocol>(_ manager: LLM) {
        unsubscribeFromLoadingManagerBlock(manager)
    }
}
