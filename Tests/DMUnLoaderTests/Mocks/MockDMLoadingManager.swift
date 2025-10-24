//
//  DMUnLoader
//
//  Created by Mykola Dementiev
//
import Foundation
import Combine
@testable import DMUnLoader

@MainActor
final class MockDMLoadingManager: DMLoadingManager {
    public let settings: DMLoadingManagerSettings
    
    @Published public var loadableState: DMLoadableType = .none
    
    convenience init() {
        self.init(loadableState: .none,
                  settings: MockDMLoadingManagerSettings(autoHideDelay: .seconds(0.2)))
    }
    
    internal init(loadableState: DMLoadableType = .none,
                  settings: DMLoadingManagerSettings = MockDMLoadingManagerSettings(autoHideDelay: .seconds(0.2))) {
        self.settings = settings
        self.loadableState = loadableState
    }
    
    func showLoading<PR: DMLoadingViewProvider>(provider: PR) {
        loadableState = .loading(
            provider: provider.eraseToAnyViewProvider()
        )
    }
    
    func showSuccess<PR: DMLoadingViewProvider>(
        _ message: DMLoadableTypeSuccess,
        provider: PR
    ) {
        loadableState = .success(
            message,
            provider: provider.eraseToAnyViewProvider()
        )
    }
    
    func showFailure<PR: DMLoadingViewProvider>(
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
