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
                startLoadingAction()
            }
            
            Button("Simulate an error") {
                let error = DMAppError.custom("Some test Error occured!")
                loadingManager.showFailure(error,
                                           onRetry: {
                    startLoadingAction()
                })
            }

            Button("Simulate success") {
                loadingManager.showSuccess("Data successfully loaded!")
            }

            Button("Hide downloads") {
                loadingManager.hide()
            }
        }
    }
    
    private func startLoadingAction() {
        loadingManager.showLoading()
        Task {
            await simulateTask()
        }
    }

    private func simulateTask() async {
        try? await Task.sleep(for: .seconds(6))
        await MainActor.run {
            loadingManager.showSuccess("Successfully completed!")
        }
    }
}
