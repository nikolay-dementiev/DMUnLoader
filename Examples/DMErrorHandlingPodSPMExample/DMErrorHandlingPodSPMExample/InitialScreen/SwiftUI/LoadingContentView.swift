//
//  File.swift
//  DMErrorHandlingPodExample
//
//  Created by Nikolay Dementiev on 28.01.2025.
//

import SwiftUI
import DMErrorHandling

internal struct LoadingContentView: View {
    @EnvironmentObject var loadingManager: DMLoadingManager
    
    var body: some View {
        VStack {
            Text(AppDelegateHelper.appDescriprtion)
                .padding()

            Button("Show downloads") {
                startLoadingActionWithSuccess()
            }
            
            Button("Simulate an error") {
                let error = DMAppError.custom("Some test Error occured!")
                loadingManager.showFailure(error,
                                           onRetry: DMButtonAction { completion in
                    startLoadingActionWithError(completion: completion)
                }
                    .retry(2)
                    .fallbackTo(DMButtonAction(self.startLoadingActionWithSuccess)))
            }

            Button("Simulate success") {
                loadingManager.showSuccess("Data successfully loaded!")
            }

            Button("Hide downloads") {
                loadingManager.hide()
            }
        }
    }
    
    private func startLoadingActionWithSuccess() {
        loadingManager.showLoading()
        
        Task {
            await simulateTask()
        }
    }
    
    func startLoadingActionWithError(completion: @escaping (DMAction.ResultType) -> Void) {
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
