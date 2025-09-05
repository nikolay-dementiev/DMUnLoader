//
//  DMUnLoaderPodExample
//
//  Created by Mykola Dementiev
//

import SwiftUI
import DMUnLoader

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
