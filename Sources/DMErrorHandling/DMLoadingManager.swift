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

/// ViewModel to save loading state
@MainActor
public final class DMLoadingManager: Identifiable, ObservableObject {
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
    
    public init(state loadableState: DMLoadableType,
                settings: DMLoadingManagerSettings) {
        self.id = UUID()
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
