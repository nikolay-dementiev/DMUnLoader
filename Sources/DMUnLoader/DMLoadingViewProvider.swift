//
//  DMUnLoader
//
//  Created by Mykola Dementiev
//

import SwiftUI

/// Supplies the views of a HUD: one while work runs, one for a failure and one for a success.
///
/// The library asks for a view on the main actor each time the HUD shows that state, so a view
/// is built for the state it shows. Every requirement has a default implementation that shows
/// the library's view with the matching settings, so a conforming type implements only what it
/// changes. Providers are equal only to themselves.
public protocol DMLoadingViewProvider: ObservableObject, Hashable {
    /// The view shown while work runs.
    associatedtype LoadingViewType: View
    /// The view shown for a failure.
    associatedtype ErrorViewType: View
    /// The view shown for a success.
    associatedtype SuccessViewType: View
    
    /// Returns the view of a loading HUD. Called on the main actor each time a loading state
    /// is shown.
    @MainActor
    func getLoadingView() -> LoadingViewType
    /// Returns the view of a failure. Called on the main actor each time a failure is shown.
    /// - Parameters:
    ///   - error: The failure the loading manager shows.
    ///   - onRetry: The retry action of that failure, or `nil` for a failure without one.
    ///   - onClose: Hides the HUD; the close control of the view runs it.
    @MainActor
    func getErrorView(error: any Error, onRetry: (any DMAction)?, onClose: any DMAction) -> ErrorViewType
    /// Returns the view of a success. Called on the main actor each time a success is shown.
    /// - Parameter object: The message passed to `showSuccess(_:provider:)`.
    @MainActor
    func getSuccessView(object: any DMLoadableTypeSuccess) -> SuccessViewType

    /// Loading manager settings carried by the provider. The library does not read them: a
    /// success or a failure hides after the `settings.autoHideDelay` of the loading manager
    /// that shows it, whatever provider it was shown with. `eraseToAnyViewProvider()` passes
    /// the value on unchanged.
    var loadingManagerSettings: any DMLoadingManagerSettings { get }
    /// The settings that the default `getLoadingView()` gives the loading view.
    var loadingViewSettings: any DMProgressViewSettings { get }
    /// The settings that the default `getErrorView(error:onRetry:onClose:)` gives the error view.
    var errorViewSettings: any DMErrorViewSettings { get }
    /// The settings that the default `getSuccessView(object:)` gives the success view.
    var successViewSettings: any DMSuccessViewSettings { get }
}

extension DMLoadingViewProvider {
    /// Compares two providers by identity: a provider is equal only to itself, whatever its
    /// hash.
    public static func == (lhs: Self,
                           rhs: Self) -> Bool {
        lhs === rhs
    }

    /// Hashes the identity of the provider into the provided hasher.
    public func hash(into hasher: inout Hasher) {
        hasher.combine(ObjectIdentifier(self))
    }
}

public extension DMLoadingViewProvider {
    
    /// The library's loading view, with `loadingViewSettings`.
    @MainActor
    func getLoadingView() -> some View {
        DMProgressView(settings: loadingViewSettings)
    }
    
    /// The library's error view, with `errorViewSettings`: the error's description, Close, and
    /// Retry when `onRetry` is not `nil`.
    @MainActor
    func getErrorView(error: any Error,
                      onRetry: (any DMAction)?,
                      onClose: any DMAction) -> some View {
        DMErrorView(settings: errorViewSettings,
                    error: error,
                    onRetry: onRetry,
                    onClose: onClose)
    }
    
    /// The library's success view, with `successViewSettings`: the description of `object`.
    @MainActor
    func getSuccessView(object: any DMLoadableTypeSuccess) -> some View {
        DMSuccessView(settings: successViewSettings,
                      assosiatedObject: object)
    }
    
    // MARK: - Default Settings

    /// Settings with an auto-hide delay of 2 seconds. Not read by the library: the loading
    /// manager's own settings decide the delay.
    var loadingManagerSettings: any DMLoadingManagerSettings {
        DMLoadingManagerDefaultSettings()
    }
    
    /// `DMProgressViewDefaultSettings()`.
    var loadingViewSettings: any DMProgressViewSettings {
        DMProgressViewDefaultSettings()
    }
    
    /// `DMErrorDefaultViewSettings()`.
    var errorViewSettings: any DMErrorViewSettings {
        DMErrorDefaultViewSettings()
    }
    
    /// `DMSuccessDefaultViewSettings()`.
    var successViewSettings: any DMSuccessViewSettings {
        DMSuccessDefaultViewSettings()
    }
}

/// The provider of the library's views, each with the settings it was given or the default of
/// its type. It conforms on the main actor, where the library asks it for views.
public class DefaultDMLoadingViewProvider: @MainActor DMLoadingViewProvider {
    /// The settings passed to the initializer, or settings with a 2-second delay. Not read by
    /// the library: the loading manager's own settings decide the delay.
    public let loadingManagerSettings: any DMLoadingManagerSettings
    /// The settings passed to the initializer, or `DMProgressViewDefaultSettings()`.
    public let loadingViewSettings: any DMProgressViewSettings
    /// The settings passed to the initializer, or `DMErrorDefaultViewSettings()`.
    public let errorViewSettings: any DMErrorViewSettings
    /// The settings passed to the initializer, or `DMSuccessDefaultViewSettings()`.
    public let successViewSettings: any DMSuccessViewSettings

    /// Creates a provider of the default loading, error and success views.
    /// - Parameters:
    ///   - loadingManagerSettings: Kept as `loadingManagerSettings` and not read by the
    ///     library; set the delay on the loading manager, `DMLoadingManagerMain(state:settings:)`.
    ///     Defaults to settings with a 2-second delay.
    ///   - loadingViewSettings: Settings of the loading view. Defaults to `DMProgressViewDefaultSettings()`.
    ///   - errorViewSettings: Settings of the error view. Defaults to `DMErrorDefaultViewSettings()`.
    ///   - successViewSettings: Settings of the success view. Defaults to `DMSuccessDefaultViewSettings()`.
    public init(
        loadingManagerSettings: (any DMLoadingManagerSettings)? = nil,
        loadingViewSettings: (any DMProgressViewSettings)? = nil,
        errorViewSettings: (any DMErrorViewSettings)? = nil,
        successViewSettings: (any DMSuccessViewSettings)? = nil
    ) {
        self.loadingManagerSettings = loadingManagerSettings ?? DMLoadingManagerDefaultSettings()
        self.loadingViewSettings = loadingViewSettings ?? DMProgressViewDefaultSettings()
        self.errorViewSettings = errorViewSettings ?? DMErrorDefaultViewSettings()
        self.successViewSettings = successViewSettings ?? DMSuccessDefaultViewSettings()
    }
}
