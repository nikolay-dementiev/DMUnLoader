//
//  DMUnLoader
//
//  Created by Mykola Dementiev
//

import SwiftUI

public final class AnyDMLoadingViewProviderTypeErasurer<
    LoadingViewType: View,
    ErrorViewType: View,
    SuccessViewType: View
>: DMLoadingViewProviderProtocol {
    public var id: UUID
    
    private let _getLoadingView: () -> LoadingViewType
    private let _getErrorView: (Error, DMAction?, DMAction) -> ErrorViewType
    private let _getSuccessView: (DMLoadableTypeSuccess) -> SuccessViewType
    private let _loadingManagerSettings: () -> DMLoadingManagerSettings
    private let _loadingViewSettings: () -> DMLoadingViewSettings
    private let _errorViewSettings: () -> DMErrorViewSettings
    private let _successViewSettings: () -> DMSuccessViewSettings
    
    public var loadingManagerSettings: DMLoadingManagerSettings { _loadingManagerSettings() }
    public var loadingViewSettings: DMLoadingViewSettings { _loadingViewSettings() }
    public var errorViewSettings: DMErrorViewSettings { _errorViewSettings() }
    public var successViewSettings: DMSuccessViewSettings { _successViewSettings() }
    
    @MainActor
    init<P>(provider: P)
    where P: DMLoadingViewProviderProtocol,
    P.LoadingViewType == LoadingViewType,
    P.ErrorViewType == ErrorViewType,
    P.SuccessViewType == SuccessViewType {
        self.id = provider.id
        self._getLoadingView = provider.getLoadingView
        self._getErrorView = provider.getErrorView(error:onRetry:onClose:)
        self._getSuccessView = provider.getSuccessView(object:)
        self._loadingManagerSettings = { provider.loadingManagerSettings }
        self._loadingViewSettings = { provider.loadingViewSettings }
        self._errorViewSettings = { provider.errorViewSettings }
        self._successViewSettings = { provider.successViewSettings }
    }
    
    @MainActor
    init(
        getLoadingView: @escaping () -> LoadingViewType,
        getErrorView: @escaping (Error, DMAction?, DMAction) -> ErrorViewType,
        getSuccessView: @escaping (DMLoadableTypeSuccess) -> SuccessViewType,
        loadingManagerSettings: DMLoadingManagerSettings,
        loadingViewSettings: DMLoadingViewSettings,
        errorViewSettings: DMErrorViewSettings,
        successViewSettings: DMSuccessViewSettings,
        id: UUID
    ) {
        self.id = id
        self._getLoadingView = getLoadingView
        self._getErrorView = getErrorView
        self._getSuccessView = getSuccessView
        self._loadingManagerSettings = { loadingManagerSettings }
        self._loadingViewSettings = { loadingViewSettings }
        self._errorViewSettings = { errorViewSettings }
        self._successViewSettings = { successViewSettings }
    }
    
    @MainActor
    public func getLoadingView() -> LoadingViewType {
        _getLoadingView()
    }
    
    @MainActor
    public func getErrorView(error: Error,
                             onRetry: DMAction?,
                             onClose: DMAction) -> ErrorViewType {
        _getErrorView(
            error,
            onRetry,
            onClose
        )
    }
    
    @MainActor
    public func getSuccessView(object: DMLoadableTypeSuccess) -> SuccessViewType {
        _getSuccessView(object)
    }
}

// MARK: - Universal type erasures

public extension DMLoadingViewProviderProtocol {
    @MainActor
    func eraseToAnyProvider() -> AnyDMLoadingViewProviderTypeErasurer<LoadingViewType, ErrorViewType, SuccessViewType> {
        AnyDMLoadingViewProviderTypeErasurer(provider: self)
    }
    
    @MainActor
    func eraseToAnyViewProvider() -> AnyDMLoadingAnyViewProvider {
        AnyDMLoadingAnyViewProvider(
            getLoadingView: {
                AnyView(
                    self.getLoadingView()
                )
            },
            getErrorView: { error, retry, close in
                AnyView(
                    self.getErrorView(
                        error: error,
                        onRetry: retry,
                        onClose: close
                    )
                )
            },
            getSuccessView: { object in
                AnyView(self.getSuccessView(object: object))
            },
            loadingManagerSettings: self.loadingManagerSettings,
            loadingViewSettings: self.loadingViewSettings,
            errorViewSettings: self.errorViewSettings,
            successViewSettings: self.successViewSettings,
            id: self.id
        )
    }
}

public typealias AnyDMLoadingAnyViewProvider = AnyDMLoadingViewProviderTypeErasurer<AnyView, AnyView, AnyView>
