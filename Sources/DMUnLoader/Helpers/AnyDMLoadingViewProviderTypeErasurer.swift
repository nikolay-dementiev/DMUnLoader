//
//  DMUnLoader
//
//  Created by Mykola Dementiev
//

import SwiftUI

/// A provider that wraps another one behind fixed view types, so that a loading state can hold
/// any provider. `eraseToAnyViewProvider()` makes it.
///
/// It keeps the settings of the wrapped provider as they were when it was made, and asks the
/// wrapped provider for each view when one is needed. It is equal only to itself.
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
    /// The `loadingViewSettings` of the erased provider at the moment it was erased.
    public var loadingViewSettings: any DMProgressViewSettings { _loadingViewSettings() }
    /// The `errorViewSettings` of the erased provider at the moment it was erased.
    public var errorViewSettings: any DMErrorViewSettings { _errorViewSettings() }
    /// The `successViewSettings` of the erased provider at the moment it was erased.
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
    
    /// The loading view of the erased provider, asked for now.
    @MainActor
    public func getLoadingView() -> LoadingViewType {
        _getLoadingView()
    }
    
    /// The error view of the erased provider for these arguments, asked for now.
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
    
    /// The success view of the erased provider for `object`, asked for now.
    @MainActor
    public func getSuccessView(object: any DMLoadableTypeSuccess) -> SuccessViewType {
        _getSuccessView(object)
    }
}

// MARK: - Universal type erasures

public extension DMLoadingViewProvider {
    /// Wraps the provider in an `AnyDMLoadingViewProvider`. The settings are read once, now;
    /// every view is built by this provider when it is needed. The wrapper does not pass on
    /// this provider's change notifications. An `AnyDMLoadingViewProvider` is returned as it is.
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

/// The erased provider that a loading state holds: each of its views is an `AnyView`.
public typealias AnyDMLoadingViewProvider = AnyDMLoadingViewProviderTypeErasurer<AnyView, AnyView, AnyView>
