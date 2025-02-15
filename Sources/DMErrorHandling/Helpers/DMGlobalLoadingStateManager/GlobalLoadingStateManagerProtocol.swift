//
//  GlobalLoadingStateManagerProtocol.swift
//  DMErrorHandling
//
//  Created by Nikolay Dementiev on 14.02.2025.
//

import Foundation

public protocol GlobalLoadingStateManagerProtocol: ObservableObject, Observable {
    var loadableState: DMLoadableType { get }
}

internal protocol GlobalLoadingStateManagerInternalProtocol: GlobalLoadingStateManagerProtocol {
    var id: UUID { get }
    var loadableState: DMLoadableType { get }
    var isLoading: Bool { get }
    @MainActor
    func subscribeToLoadingManagers<LLM: DMLoadingManagerInteralProtocol>(_ loadingManagers: LLM...)
    @MainActor
    func unsubscribeFromLoadingManager<LLM: DMLoadingManagerInteralProtocol>(_ manager: LLM)
}
