//
//  DMUnLoaderPodSPMExample
//
//  Created by Mykola Dementiev
//

import Foundation
import DMUnLoader

/// The `LoadingContentViewModel` is the ViewModel responsible for managing the state and actions
/// related to loading, success, and error scenarios in the UI. It adheres to the MVVM pattern
/// and provides methods for simulating tasks, handling errors, and interacting with the
/// `DMLoadingManager`.
@MainActor
final class LoadingContentViewModel<Provider: DMLoadingViewProvider,
                                    LM: DMLoadingManager>: ObservableObject {
    
    /// The `DMLoadingManager` instance used to manage loading states, show success messages,
    /// or display error dialogs. This property is optional and must be configured before use.
    private var loadingManager: LM?
    private var provider: Provider?
    
    /// A published property indicating whether the `ViewModel` is ready to handle actions.
    /// This property is `true` when the `loadingManager` is properly configured, and `false` otherwise.
    @Published var isReady: Bool = false
    
    /**
     Configures the `ViewModel` by setting the `DMLoadingManager` instance.
     
     - Parameter loadingManager: An optional `DMLoadingManager` instance. If `nil`, the `ViewModel`
       will remain in an uninitialized state (`isReady = false`).
     */
    func configure(loadingManager: LM?, provider: Provider?) {
        self.loadingManager = loadingManager
        self.provider = provider
        self.isReady = self.loadingManager != nil
    }
    
    /**
     Simulates the "Show downloads" action by initiating a successful loading task.
     
     This method calls `startLoadingActionWithSuccess()` internally to simulate a successful operation.
     */
    @objc func showDownloads() {
        startLoadingActionWithSuccess()
    }
    
    /**
     Simulates an error scenario by triggering a failure dialog with retry and fallback options.
     
     - Behavior:
       - Displays a failure dialog using the `DMLoadingManager`.
       - Provides a retry action that attempts to execute the task again.
       - Includes a fallback action that triggers a successful completion if retries fail.
     */
    @objc func simulateAnError() {
        guard let loadingManager = loadingManager, let provider = provider else {
            print("Error: loadingManager is not set")
            return
        }
        
        let error = DMAppError.custom("Some test Error occured!")
        loadingManager.showFailure(error,
                                   provider: provider,
                                   onRetry: DMButtonAction { [weak self] completion in
            self?.startLoadingActionWithError(completion: completion)
        }
            .retry(2)
            .fallbackTo(DMButtonAction(startLoadingActionWithSuccess)))
    }
    
    /**
     Simulates a success scenario by displaying a success message via the `DMLoadingManager`.
     
     - Note: This method requires the `loadingManager` to be configured. If `loadingManager` is `nil`,
       an error message is logged, and no action is taken.
     */
    @objc func simulateSuccess() {
        guard let loadingManager = loadingManager, let provider = provider else {
            print("Error: loadingManager is not set")
            return
        }
        
        loadingManager.showSuccess("Data successfully loaded!",
                                   provider: provider)
    }
    
    /**
     Hides the loading indicator or any active UI elements managed by the `DMLoadingManager`.
     
     - Note: This method requires the `loadingManager` to be configured. If `loadingManager` is `nil`,
       an error message is logged, and no action is taken.
     */
    @objc func hideLoading() {
        guard let loadingManager = loadingManager else {
            print("Error: loadingManager is not set")
            return
        }
        
        loadingManager.hide()
    }
    
    /**
     Initiates a loading action that simulates a successful task after a delay.
     
     - Behavior:
       - Displays a loading indicator via the `DMLoadingManager`.
       - Simulates a task using `simulateTask()`, which completes successfully after a delay.
     */
    private func startLoadingActionWithSuccess() {
        guard let loadingManager = loadingManager, let provider = provider else {
            print("Error: loadingManager is not set")
            return
        }
        
        loadingManager.showLoading(provider: provider)
        
        Task {
            await simulateTask()
        }
    }
    
    /**
     Initiates a loading action that may result in an error.
     
     - Parameters:
       - completion: A closure that receives the result of the task as a `Result<Copyable, Error>`.
     
     - Behavior:
       - Displays a loading indicator via the `DMLoadingManager`.
       - Simulates a task using `simulateTaskWithError()`, which may throw an error after a delay.
       - Passes the result (success or failure) to the `completion` handler.
     */
    private func startLoadingActionWithError(completion: @escaping (DMAction.ResultType) -> Void) {
        guard let loadingManager = loadingManager, let provider = provider else {
            print("Error: loadingManager is not set")
            return
        }
        
        loadingManager.showLoading(provider: provider)
        
        Task {
            let result = await withCheckedContinuation { (continuation: CheckedContinuation<DMAction.ResultType, Never>) in
                Task {
                    do {
                        // Call the asynchronous task
                        try await simulateTaskWithError()
                        
                        continuation.resume(returning: .success(PlaceholderCopyable()))
                    } catch {
                        // If an error occurs, return a failure result with the error
                        continuation.resume(returning: .failure(error))
                    }
                }
            }
            
            // Pass the result to the completion handler
            completion(result)
        }
    }
    
    /**
     Simulates a successful task by introducing a 6-second delay and displaying a success message.
     
     - Behavior:
       - Waits for 6 seconds using `Task.sleep(for:)`.
       - Displays a success message via the `DMLoadingManager` after the delay.
     */
    private func simulateTask() async {
        guard let loadingManager = loadingManager, let provider = provider else {
            print("Error: loadingManager is not set")
            return
        }
        
        try? await Task.sleep(for: .seconds(6))
        await MainActor.run {
            loadingManager.showSuccess(
                "Successfully completed!",
                provider: provider
            )
        }
    }
    
    /**
     Simulates a task that throws an error after a 6-second delay.
     
     - Behavior:
       - Waits for 6 seconds using `Task.sleep(for:)`.
       - Throws an `NSError` with a custom domain and code after the delay.
     */
    private func simulateTaskWithError() async throws {
        try? await Task.sleep(for: .seconds(6))
        
        throw NSError(domain: "TestErrorDomain", code: 1, userInfo: nil)
    }
}
