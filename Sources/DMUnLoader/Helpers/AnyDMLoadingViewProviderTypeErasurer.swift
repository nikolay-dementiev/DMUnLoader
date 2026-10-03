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
>: DMLoadingViewProvider {
    private let _getLoadingView: () -> LoadingViewType
    private let _getErrorView: (Error, DMAction?, DMAction) -> ErrorViewType
    private let _getSuccessView: (DMLoadableTypeSuccess) -> SuccessViewType
    private let _loadingManagerSettings: () -> DMLoadingManagerSettings
    private let _loadingViewSettings: () -> DMProgressViewSettings
    private let _errorViewSettings: () -> DMErrorViewSettings
    private let _successViewSettings: () -> DMSuccessViewSettings
    
    public var loadingManagerSettings: DMLoadingManagerSettings { _loadingManagerSettings() }
    public var loadingViewSettings: DMProgressViewSettings { _loadingViewSettings() }
    public var errorViewSettings: DMErrorViewSettings { _errorViewSettings() }
    public var successViewSettings: DMSuccessViewSettings { _successViewSettings() }
    
    @MainActor
    init(
        getLoadingView: @escaping () -> LoadingViewType,
        getErrorView: @escaping (Error, DMAction?, DMAction) -> ErrorViewType,
        getSuccessView: @escaping (DMLoadableTypeSuccess) -> SuccessViewType,
        loadingManagerSettings: DMLoadingManagerSettings,
        loadingViewSettings: DMProgressViewSettings,
        errorViewSettings: DMErrorViewSettings,
        successViewSettings: DMSuccessViewSettings
    ) {
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

public extension DMLoadingViewProvider {
    @MainActor
    func eraseToAnyViewProvider() -> AnyDMLoadingViewProvider {
        if let castedSelf = self as? AnyDMLoadingViewProvider {
            return castedSelf
        }
        
        return AnyDMLoadingViewProvider(
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
            successViewSettings: self.successViewSettings
        )
    }
}

public typealias AnyDMLoadingViewProvider = AnyDMLoadingViewProviderTypeErasurer<AnyView, AnyView, AnyView>
