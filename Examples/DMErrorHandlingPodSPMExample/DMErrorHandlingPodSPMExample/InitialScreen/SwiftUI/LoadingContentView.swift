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
    @StateObject var viewModel = LoadingContentViewModel()

    var body: some View {
        VStack {
            Text(AppDelegateHelper.appDescriprtion)
                .padding()

            Button("Show downloads", action: viewModel.showDownloads)
            Button("Simulate an error", action: viewModel.simulateAnError)
            Button("Simulate success", action: viewModel.simulateSuccess)
            Button("Hide downloads", action: viewModel.hideLoading)
            
        }.onAppear {
            viewModel.configure(loadingManager: loadingManager)
        }.disabled(!viewModel.isReady)
    }
}
