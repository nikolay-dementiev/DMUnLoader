//
//  DMUnLoaderPodExample
//
//  Created by Mykola Dementiev
//

import SwiftUI
import DMUnLoader

internal struct LoadingContentViewSwiftUI<LM: DMLoadingManagerInteralProtocol>: View {
    var loadingManager: LM
    @StateObject var viewModel = LoadingContentViewModel<LM>()
    
    var body: some View {
        VStack {
            Text(AppDelegateHelper.appDescriprtion)
                .padding()
            
            Group {
                Button("Simulate Loading", action: viewModel.showDownloads)
                    .buttonStyle(.borderedCorner)
                Button("Simulate Error", action: viewModel.simulateAnError)
                    .buttonStyle(.borderedCorner)
                Button("Simulate Success", action: viewModel.simulateSuccess)
                    .buttonStyle(.borderedCorner)
            }
            .padding(.vertical, 3)
        }
        .fixedSize(horizontal: true, vertical: false)
        .onAppear {
            viewModel.configure(loadingManager: loadingManager)
        }.disabled(!viewModel.isReady)
    }
}

#Preview("LoadingContent") {
    LoadingContentViewSwiftUI(loadingManager: DMLoadingManager())
}
