//
//  DMErrorHandling
//
//  Created by Mykola Dementiev
//

import Foundation
import Combine
import DMAction

/// ViewModel to handle loading state
@MainActor
public final class DMLoadingManager: DMLoadingManagerInteralProtocol {
    public let id: UUID
    public let settings: DMLoadingManagerSettings
    private let loadableStateSubject = PassthroughSubject<DMLoadableType, Never>()
    
    @Published internal(set) public var loadableState: DMLoadableType = .none {
        willSet {
            loadableStateSubject.send(newValue)
        }
    }
    
    internal var loadableStatePublisher: AnyPublisher<DMLoadableType, Never> {
        loadableStateSubject.eraseToAnyPublisher()
    }
    
    private var inactivityTimerCancellable: AnyCancellable?
    
    public init(id: UUID = UUID(),
                state loadableState: DMLoadableType,
                settings: DMLoadingManagerSettings) {
        self.id = id
        self.loadableState = loadableState
        self.settings = settings
    }
    
    public func showLoading() {
        stopInactivityTimer()
        
        loadableState = .loading
    }
    
    public func showSuccess(_ message: DMLoadableTypeSuccess) {
        startInactivityTimer()
        
        loadableState = .success(message)
    }
    
    public func showFailure(_ error: Error, onRetry: DMAction? = nil) {
        startInactivityTimer()
        
        loadableState = .failure(error: error, onRetry: onRetry)
    }
    
    public func hide() {
        loadableState = .none
    }
    
    // Timer
    
    // Start inactivity timer
    private func startInactivityTimer() {
        stopInactivityTimer()

        inactivityTimerCancellable = Deferred {
            Future<Void, Never> { promise in
                promise(.success(()))
            }
        }
        .delay(for: .seconds(settings.autoHideDelay.timeInterval),
               scheduler: RunLoop.main)
        .sink(receiveValue: { [weak self] _ in
            self?.hide()
        })
    }
    
    // Stopping the timer
    private func stopInactivityTimer() {
        inactivityTimerCancellable?.cancel()
        inactivityTimerCancellable = nil
    }
}

extension DMLoadingManager: Hashable {
    nonisolated public static func == (lhs: DMLoadingManager,
                                       rhs: DMLoadingManager) -> Bool {
        lhs.hashValue == rhs.hashValue
    }
    
    nonisolated public func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}
