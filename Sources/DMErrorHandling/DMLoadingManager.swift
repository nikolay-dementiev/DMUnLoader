//
//  DMLoadingManager.swift
//  DMErrorHandling
//
//  Created by Nikolay Dementiev on 24.01.2025.
//

import Foundation
import Combine

public protocol DMLoadingManagerSettings {
    var autoHideDelay: Duration { get }
}

internal struct DMLoadingManagerDefaultSettings: DMLoadingManagerSettings {
    let autoHideDelay: Duration
    
    internal init(autoHideDelay: Duration = .seconds(2)) {
        self.autoHideDelay = autoHideDelay
    }
}


//TODO: make LoadingManager as @Sendable

/// ViewModel to save loading state
@MainActor
public final class DMLoadingManager: ObservableObject {
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
    
    public init(state loadableState: DMLoadableType,
                settings: DMLoadingManagerSettings) {
        self.loadableState = loadableState
        self.settings = settings
    }
    
    public func showLoading() {
        stopInactivityTimer()
        
        loadableState = .loading
    }
    
    public func showSuccess(_ message: Any) {
        startInactivityTimer()
        
        loadableState = .success(message)
    }
    
    public func showFailure(_ error: Error, onRetry: (() -> Void)? = nil) {
        startInactivityTimer()
        
        loadableState = .failure(error: error, onRetry: onRetry)
    }
    
    public func hide() {
        loadableState = .none
    }
    
    internal func stopTimerAndHide() {
        stopInactivityTimer()
        hide()
    }
    
    //Timer
    
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
    
    // Reset the timer
    public func resetInactivityTimer() {
        startInactivityTimer()
    }
    
    // Stopping the timer
    private func stopInactivityTimer() {
        inactivityTimerCancellable?.cancel()
        inactivityTimerCancellable = nil
    }
}
