//
//  DMUnLoader
//
//  Created by Mykola Dementiev
//
import Foundation
import Combine
@testable import DMUnLoader

@MainActor
final class MockDMLoadingManager: DMLoadingManagerInteralProtocol {
    
    public let id: UUID
    public let settings: DMLoadingManagerSettings
    
    @Published public var loadableState: DMLoadableType = .none
    public var loadableStatePublisher: AnyPublisher<DMLoadableType, Never> {
        $loadableState.eraseToAnyPublisher()
    }
    
    convenience init() {
        self.init(id: UUID(),
                  loadableState: .none,
                  settings: MockDMLoadingManagerSettings(autoHideDelay: .seconds(0.2)))
    }
    
    internal init(id: UUID = UUID(),
                  loadableState: DMLoadableType = .none,
                  settings: DMLoadingManagerSettings = MockDMLoadingManagerSettings(autoHideDelay: .seconds(0.2))) {
        self.id = id
        self.settings = settings
        self.loadableState = loadableState
    }
    
    func showLoading<PR: DMLoadingViewProviderProtocol>(provider: PR) {
        loadableState = .loading(
            provider: provider.eraseToAnyViewProvider()
        )
    }

    func showSuccess<PR: DMLoadingViewProviderProtocol>(
        _ message: DMLoadableTypeSuccess,
        provider: PR
    ) {
        loadableState = .success(
            message,
            provider: provider.eraseToAnyViewProvider()
        )
    }
    
    func showFailure<PR: DMLoadingViewProviderProtocol>(
        _ error: Error,
        provider: PR,
        onRetry: DMAction?
    ) {
        loadableState = .failure(
            error: error,
            provider: provider.eraseToAnyViewProvider(),
            onRetry: onRetry
        )
    }
    
    public func hide() {
        loadableState = .none
    }
}
