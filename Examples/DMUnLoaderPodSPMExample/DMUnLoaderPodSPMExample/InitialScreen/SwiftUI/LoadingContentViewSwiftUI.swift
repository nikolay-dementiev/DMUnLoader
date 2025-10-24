//
//  DMUnLoaderPodExample
//
//  Created by Mykola Dementiev
//

import SwiftUI
import DMUnLoader

struct LoadingContentViewSwiftUI<Provider: DMLoadingViewProvider,
                                 LM: DMLoadingManager>: View {
    var loadingManager: LM
    var provider: Provider
    @StateObject var viewModel = LoadingContentViewModel<Provider,LM>()
    
    var body: some View {
        VStack {
            Text(AppDelegateHelper.appDescriprtion)
                .padding()
            
            Group {
                Button("Simulate Loading", action: viewModel.showDownloads)
                    .buttonStyle(.dmBorderedCorner)
                Button("Simulate Error", action: viewModel.simulateAnError)
                    .buttonStyle(.dmBorderedCorner)
                Button("Simulate Success", action: viewModel.simulateSuccess)
                    .buttonStyle(.dmBorderedCorner)
            }
            .padding(.vertical, 3)
        }
        .fixedSize(horizontal: true, vertical: false)
        .onAppear {
            viewModel.configure(
                loadingManager: loadingManager,
                provider: provider
            )
        }.disabled(!viewModel.isReady)
    }
}

#Preview("LoadingContent") {
    LoadingContentViewSwiftUI(loadingManager: DMLoadingManagerMain(),
                              provider: DefaultDMLoadingViewProvider())
}
