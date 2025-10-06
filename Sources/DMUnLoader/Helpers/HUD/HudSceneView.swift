//
//  DMUnLoader
//
//  Created by Mykola Dementiev
//

import SwiftUI

struct HudSceneView<LM: DMLoadingManagerProtocol>: View {
    @ObservedObject var loadingManager: LM

    init(loadingManager: LM) {
        self.loadingManager = loadingManager
    }
    
    var body: some View {
        Color.clear
            .ignoresSafeArea(.all)
            .hudCenter(loadingManager: loadingManager) {
                DMLoadingView(loadingManager: loadingManager,
                              provider: DefaultDMLoadingViewProvider())
            }
    }
}

#Preview("Error") {
    let loadingManager = DMLoadingManager(
        state: .failure(
            error: DMAppError.custom("Something went wrong"),
            onRetry: DMButtonAction({ _ in })
        ),
        settings: DMLoadingManagerDefaultSettings()
    )
    
    HudSceneView(loadingManager: loadingManager)
}

#Preview("Loading") {
    let loadingManager = DMLoadingManager(
        state: .loading,
        settings: DMLoadingManagerDefaultSettings()
    )
    
    HudSceneView(loadingManager: loadingManager)
}

#Preview("Success") {
    let loadingManager = DMLoadingManager(
        state: .success("Wow! All were done!"),
        settings: DMLoadingManagerDefaultSettings()
    )
    
    HudSceneView(loadingManager: loadingManager)
}

#Preview("None") {
    let loadingManager = DMLoadingManager(
        state: .none,
        settings: DMLoadingManagerDefaultSettings()
    )
    
    HudSceneView(loadingManager: loadingManager)
}
