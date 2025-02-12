//
//  LoadingContentViewViewModel.swift
//  DMErrorHandlingPodSPMExample
//
//  Created by Nikolay Dementiev on 12.02.2025.
//

import Foundation
import DMErrorHandling

@MainActor
final class LoadingContentViewModel: ObservableObject {
    private var loadingManager: DMLoadingManager?
    @Published var isReady: Bool = false
    
    func configure(loadingManager: DMLoadingManager?) {
        self.loadingManager = loadingManager
        self.isReady = self.loadingManager != nil
    }
    
    @objc func showDownloads() {
        startLoadingActionWithSuccess()
    }
    
    @objc func simulateAnError() {
        guard let loadingManager = loadingManager else {
            print("Error: loadingManager is not set")
            return
        }
        
        let error = DMAppError.custom("Some test Error occured!")
        loadingManager.showFailure(error,
                                   onRetry: DMButtonAction { [weak self] completion in
            self?.startLoadingActionWithError(completion: completion)
        }
            .retry(2)
            .fallbackTo(DMButtonAction(startLoadingActionWithSuccess)))
    }
    
    @objc func simulateSuccess() {
        guard let loadingManager = loadingManager else {
            print("Error: loadingManager is not set")
            return
        }
        
        loadingManager.showSuccess("Data successfully loaded!")
    }
    
    @objc func hideLoading() {
        guard let loadingManager = loadingManager else {
            print("Error: loadingManager is not set")
            return
        }
        
        loadingManager.hide()
    }
    
    private func startLoadingActionWithSuccess() {
        guard let loadingManager = loadingManager else {
            print("Error: loadingManager is not set")
            return
        }
        
        loadingManager.showLoading()
        
        Task {
            await simulateTask()
        }
    }
    
    private func startLoadingActionWithError(completion: @escaping (DMAction.ResultType) -> Void) {
        guard let loadingManager = loadingManager else {
            print("Error: loadingManager is not set")
            return
        }
        
        loadingManager.showLoading()
        
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
    
    private func simulateTask() async {
        guard let loadingManager = loadingManager else {
            print("Error: loadingManager is not set")
            return
        }
        
        try? await Task.sleep(for: .seconds(6))
        await MainActor.run {
            loadingManager.showSuccess("Successfully completed!")
        }
    }
    
    private func simulateTaskWithError() async throws {
        try? await Task.sleep(for: .seconds(6))
        
        throw NSError(domain: "TestErrorDomain", code: 1, userInfo: nil)
    }
}
