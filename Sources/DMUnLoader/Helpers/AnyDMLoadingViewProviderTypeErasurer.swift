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
    private let _getErrorView: (any Error, (any DMAction)?, any DMAction) -> ErrorViewType
    private let _getSuccessView: (any DMLoadableTypeSuccess) -> SuccessViewType
    private let _loadingManagerSettings: () -> any DMLoadingManagerSettings
    private let _loadingViewSettings: () -> any DMProgressViewSettings
    private let _errorViewSettings: () -> any DMErrorViewSettings
    private let _successViewSettings: () -> any DMSuccessViewSettings

    /// The provider this one was made from. Its views keep that provider alive, so the
    /// identifier cannot belong to another object while this one exists.
    let wrappedProviderID: ObjectIdentifier

    /// The `loadingManagerSettings` of the erased provider at the moment it was erased. Not
    /// read by the library.
    public var loadingManagerSettings: any DMLoadingManagerSettings { _loadingManagerSettings() }
    public var loadingViewSettings: any DMProgressViewSettings { _loadingViewSettings() }
    public var errorViewSettings: any DMErrorViewSettings { _errorViewSettings() }
    public var successViewSettings: any DMSuccessViewSettings { _successViewSettings() }
    
    @MainActor
    init(
        getLoadingView: @escaping () -> LoadingViewType,
        getErrorView: @escaping (any Error, (any DMAction)?, any DMAction) -> ErrorViewType,
        getSuccessView: @escaping (any DMLoadableTypeSuccess) -> SuccessViewType,
        loadingManagerSettings: any DMLoadingManagerSettings,
        loadingViewSettings: any DMProgressViewSettings,
        errorViewSettings: any DMErrorViewSettings,
        successViewSettings: any DMSuccessViewSettings,
        wrappedProviderID: ObjectIdentifier
    ) {
        self.wrappedProviderID = wrappedProviderID
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
    public func getErrorView(error: any Error,
                             onRetry: (any DMAction)?,
                             onClose: any DMAction) -> ErrorViewType {
        _getErrorView(
            error,
            onRetry,
            onClose
        )
    }
    
    @MainActor
    public func getSuccessView(object: any DMLoadableTypeSuccess) -> SuccessViewType {
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
            successViewSettings: self.successViewSettings,
            wrappedProviderID: ObjectIdentifier(self)
        )
    }
}

public typealias AnyDMLoadingViewProvider = AnyDMLoadingViewProviderTypeErasurer<AnyView, AnyView, AnyView>
