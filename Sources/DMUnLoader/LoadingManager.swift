//
//  DMUnLoader
//
//  Created by Mykola Dementiev
//

import Combine
import Foundation

public protocol LoadingManager {
    var settings: DMLoadingManagerSettings { get }
    var currentState: DMLoadableState { get }
    func show(state: DMLoadableState)
    func hide()
}

public class DMLoadingManagerService: LoadingManager {
    public let settings: DMLoadingManagerSettings
    
    public var currentState: DMLoadableState {
        _currentState()
    }
    
    private var _currentState: Atomic<DMLoadableState>
    private var inactivityTimerCancellable: AnyCancellable?
    
    public init(withState state: DMLoadableState = .idle,
                settings: DMLoadingManagerSettings = DMLoadingManagerSettings()) {
        self._currentState = Atomic(state)
        self.settings = settings
    }
    
    public func show(state: DMLoadableState) {
        switch state {
        case .loading,
                .idle:
            stopInactivityTimer()
        default:
            startInactivityTimer()
        }
        
        _currentState.mutate { [state] prop in
            prop = state
        }
    }
    
    public func hide() {
        show(state: .idle)
    }
    
    // MARK: Timer Management
    
    /// Starts the inactivity timer, which automatically hides the loading state after the specified delay.
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
    
    /// Stops the inactivity timer, canceling any pending auto-hide operations.
    private func stopInactivityTimer() {
        inactivityTimerCancellable?.cancel()
        inactivityTimerCancellable = nil
    }
}

public struct DMLoadingManagerSettings {
    public let autoHideDelay: Duration
    
    public init(autoHideDelay: Duration = .seconds(2)) {
        self.autoHideDelay = autoHideDelay
    }
}
