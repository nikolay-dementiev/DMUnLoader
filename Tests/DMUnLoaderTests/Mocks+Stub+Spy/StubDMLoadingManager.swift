//
//  DMUnLoader
//
//  Created by Mykola Dementiev
//
import Foundation
import Combine
@testable import DMUnLoader

@MainActor
final class StubDMLoadingManager: DMLoadingManager {
    public let settings: any DMLoadingManagerSettings
    
    @Published var loadableState: DMLoadableType = .none
    
    convenience init() {
        self.init(loadableState: .none,
                  settings: StubDMLoadingManagerSettings(autoHideDelay: .seconds(0.2)))
    }
    
    init(loadableState: DMLoadableType = .none,
         settings: any DMLoadingManagerSettings = StubDMLoadingManagerSettings(autoHideDelay: .seconds(0.2))) {
        self.settings = settings
        self.loadableState = loadableState
    }
    
    func showLoading<PR: DMLoadingViewProvider>(provider: PR) {
        loadableState = .loading(
            provider: provider.eraseToAnyViewProvider()
        )
    }
    
    func showSuccess<PR: DMLoadingViewProvider>(
        _ message: any DMLoadableTypeSuccess,
        provider: PR
    ) {
        loadableState = .success(
            message,
            provider: provider.eraseToAnyViewProvider()
        )
    }
    
    func showFailure<PR: DMLoadingViewProvider>(
        _ error: any Error,
        provider: PR,
        onRetry: (any DMAction)?
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
