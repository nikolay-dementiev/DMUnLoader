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
    
    public func showLoading() {
        loadableState = .loading
    }
    
    public func showSuccess(_ message: DMLoadableTypeSuccess) {
        loadableState = .success(message)
    }
    
    public func showFailure(_ error: Error, onRetry: DMAction? = nil) {
        loadableState = .failure(error: error, onRetry: onRetry)
    }
    
    public func hide() {
        loadableState = .none
    }
}
