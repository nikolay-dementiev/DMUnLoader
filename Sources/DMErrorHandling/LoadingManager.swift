//
//  LoadingManager.swift
//  DMErrorHandling
//
//  Created by Nikolay Dementiev on 24.01.2025.
//

import Foundation

public protocol LoadingManagerSettings {
    var autoHideDelay: Duration { get }
}

internal struct LoadingManagerDefaultSettings: LoadingManagerSettings {
    let autoHideDelay: Duration
    
    internal init(autoHideDelay: Duration = .seconds(2)) {
        self.autoHideDelay = autoHideDelay
    }
}

/// ViewModel to save loading state
//TODO: make LoadingManager as @Sendable
public final class LoadingManager: ObservableObject {
    public let settings: LoadingManagerSettings
    
    @Published internal(set) public var loadableState: LoadableType = .none
    private var inactivityTimer: Timer?
    
    public init(loadableState: LoadableType = .none,
                settings: LoadingManagerSettings? = nil) {
        self.loadableState = loadableState
        self.settings = settings ?? LoadingManagerDefaultSettings()
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
        //TODO: maybe need to inject `startInactivityTimer` into `onRetry` block
        
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
        let interval: TimeInterval = settings.autoHideDelay.timeInterval
        inactivityTimer = Timer.scheduledTimer(withTimeInterval: interval, repeats: false) { [weak self] _ in
            print(#function + ": hide: Close form after `\(interval)` second(/s) of inactivity")
            self?.hide()
        }
    }
    
    // Reset the timer
    public func resetInactivityTimer() {
        startInactivityTimer()
    }
    
    // Stopping the timer
    private func stopInactivityTimer() {
        inactivityTimer?.invalidate()
    }
}

//TODO: swap realization `LoadingManager`
//use modern approaches:  (Task / Async \ Await)/ See code below

/*
public final class LoadingManager: ObservableObject {
    public let settings: LoadingManagerSettings
    @Published private(set) public var loadableState: LoadableType = .none
    
    private var inactivityTask: Task<Void, Never>?
    
    public init(loadableState: LoadableType = .none,
                settings: LoadingManagerSettings? = nil) {
        
        self.loadableState = loadableState
        self.settings = settings ?? LoadingManagerDefaultSettings()
    }
    
    public func showLoading() {
        setState(.loading)
    }
    
    public func showSuccess(_ message: Any) {
        setState(.success(message))
        startAutoHide()
    }
    
    public func showFailure(_ error: Error, onRetry: (() -> Void)? = nil) {
        setState(.failure(error: error, onRetry: onRetry))
        startAutoHide()
    }
    
    public func hide() {
        setState(.none)
    }
    
    // MARK: - Private Methods
    
    private func setState(_ state: LoadableType) {
        cancelAutoHide()
        
        Task { @MainActor in
            self.loadableState = state
        }
    }
    
    private func startAutoHide() {
        inactivityTask = Task {
            do {
                try await Task.sleep(for: settings.autoHideDelay)
                
                // If the task was canceled, complete without taking any action
                try Task.checkCancellation()
                
                await hideOnMain()
           } catch {
                guard !(error is CancellationError) else {
                    return
                }
                print("Auto-hide task failed with error: \(error.localizedDescription)")
            }
        }
    }
    
    private func cancelAutoHide() {
        inactivityTask?.cancel()
        inactivityTask = nil
    }
    
    private func hideOnMain() async {
        await MainActor.run {
            hide()
            print("hide: Close after `\(settings.autoHideDelay)` seconds of inactivity")
        }
    }
}
*/
