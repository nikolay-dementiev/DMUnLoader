//
//  DMErrorHandling
//
//  Created by Mykola Dementiev
//

import Foundation
import Combine

@MainActor
public protocol DMLoadingManagerProtocol: Identifiable, ObservableObject {
    /// A unique identifier for the loading manager.
    var id: UUID { get }
    
    /// The settings used by the loading manager.
    var settings: DMLoadingManagerSettings { get }
    
    /// Shows the loading state.
    func showLoading()
    
    /// Shows the success state with a success message.
    func showSuccess(_ message: DMLoadableTypeSuccess)
    
    /// Shows the failure state with an error and an optional retry action.
    func showFailure(_ error: Error, onRetry: DMAction?)
    
    /// Hides the loading state (sets it to `.none`).
    func hide()
}

@MainActor
internal protocol DMLoadingManagerInteralProtocol: DMLoadingManagerProtocol {
    /// The current loadable state of the manager (e.g., `.none`, `.loading`, `.success`, `.failure`).
    var loadableState: DMLoadableType { get set }
    
    /// A publisher that emits changes to the `loadableState`.
    var loadableStatePublisher: AnyPublisher<DMLoadableType, Never> { get }
}
