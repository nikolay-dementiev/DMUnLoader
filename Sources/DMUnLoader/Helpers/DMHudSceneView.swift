//
//  DMUnLoader
//
//  Created by Mykola Dementiev
//

import SwiftUI

struct DMHudSceneView<LM: DMLoadingManagerProtocol>: View {
    @ObservedObject var loadingManager: LM

    init(loadingManager: LM) {
        self.loadingManager = loadingManager
    }
    
    var body: some View {
        Color.clear
            .ignoresSafeArea(.all)
            .hudCenter(loadingManager: loadingManager) {
                DMLoadingView(loadingManager: loadingManager)
            }
    }
}

#Preview("Error") {
    let loadingManager = DMLoadingManager(
        state: .failure(
            error: DMAppError.custom("Something went wrong"),
            provider: DefaultDMLoadingViewProvider()
                .eraseToAnyViewProvider(),
            onRetry: DMButtonAction({ _ in })
        ),
        settings: DMLoadingManagerDefaultSettings()
    )
    
    DMHudSceneView(loadingManager: loadingManager)
}

#Preview("Loading") {
    let loadingManager = DMLoadingManager(
        state: .loading(
            provider: DefaultDMLoadingViewProvider()
                .eraseToAnyViewProvider(),
        ),
        settings: DMLoadingManagerDefaultSettings()
    )
    
    DMHudSceneView(loadingManager: loadingManager)
}

#Preview("Success") {
    let loadingManager = DMLoadingManager(
        state: .success(
            "Wow! All were done!",
            provider: DefaultDMLoadingViewProvider()
                .eraseToAnyViewProvider(),
        ),
        settings: DMLoadingManagerDefaultSettings()
    )
    
    DMHudSceneView(loadingManager: loadingManager)
}

#Preview("None") {
    let loadingManager = DMLoadingManager(
        state: .none,
        settings: DMLoadingManagerDefaultSettings()
    )
    
    DMHudSceneView(loadingManager: loadingManager)
}
